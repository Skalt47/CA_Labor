/*  Radio signal clock - DCF77 Module

    Computerarchitektur 3
    (C) 2018 J. Friedrich, W. Zimmermann Hochschule Esslingen

    Author:   W.Zimmermann, Jun  10, 2016
    Modified: Erguen Bickici & Tim Jauch
*/

/*
; A C H T U N G:  D I E S E  S O F T W A R E  I S T  U N V O L L S T Ä N D I G
; Dieses Modul enthält nur Funktionsrahmen, die von Ihnen ausprogrammiert werden
; sollen.
*/

#ifndef _HCS12_SERIALMON
    #ifndef SIMULATOR 
#define SIMULATOR 1
    #endif
#endif

#include <hidef.h>                                      // Common defines
#include <mc9s12dp256.h>                                // CPU specific defines
#include <stdio.h>

#include "dcf77.h"
#include "led.h"
#include "clock.h"
#include "lcd.h"

// Global variable holding the last DCF77 event
DCF77EVENT dcf77Event = NODCF77EVENT;

// Modul internal global variables
static int  dcf77Year=2017, dcf77Month=1, dcf77Weekday=7, dcf77Day=1, dcf77Hour=0, dcf77Minute=0;       //dcf77 Date and time as integer values
unsigned char bit=0, error=0, mode=0;
int prevTime=0, prevSignal=0;
unsigned int counter=0;
char weekday[5], databits[60];

// Prototypes of functions simulation DCF77 signals, when testing without
// a DCF77 radio signal receiver
void initializePortSim(void);                   // Use instead of initializePort() for testing
char readPortSim(void);                         // Use instead of readPort() for testing

// ****************************************************************************
// Initalize the hardware port on which the DCF77 signal is connected as input
// Parameter:   -
// Returns:     -
void initializePort(void)
{
    // Configure Port H.0 as input
    DDRH &= ~(0x01); // Clear bit 0 of DDRH to set PH0 as input
    
    // Enable pull-up resistor on Port H.0 if required
    PERH |= 0x01;    // Set bit 0 of PERH to enable pull-up resistor on PH0

    // Configure Port B.0, B.1, B.2, and B.3 as output for LEDs
    DDRB |= 0x0F;    // Set lower nibble (bits 0-3) of DDRB to configure PB0-PB3 as output
}

#ifndef SIMULATOR                               // If simulator not active set SIMULATOR to 0
  #define SIMULATOR 0
#endif

#if SIMULATOR == 0                              // call readPortSim() if Simulator active

// ****************************************************************************
// Read the hardware port on which the DCF77 signal is connected as input
// Parameter:   -
// Returns:     0 if signal is Low, >0 if signal is High
char readPort(void)
{
    // Read the value of Port H.0
    if (PTH & 0x01) {
        return 1;                               // Signal is High
    } else {
        return 0;                               // Signal is Low
    }
}

#else 

char readPort(void)
{
    // Start Simulator readPost
    return readPortSim();
}

#endif

// ****************************************************************************
//  Initialize DCF77 module
//  Called once before using the module
void initDCF77(void)
{   
    setClock((char) dcf77Hour, (char) dcf77Minute, 0);
    displayDateDcf77();

    initializePort();
}

// ****************************************************************************
// Display the date derived from the DCF77 signal on the LCD display, line 1
// Parameter:   -
// Returns:     -
void displayDateDcf77(void)
{   
    // Define Variables to store the value, to not change the dcf77 values
    char datum[32];
    int day = dcf77Day, month = dcf77Month, year = dcf77Year, _weekday = dcf77Weekday;
    int carry = 0;

    // For US time zone
    if(mode == 1) {
      // HOUR
      if(dcf77Hour - 6 < 0) {                   // If minus 6 hours results in the day before set carry to 1
        carry = 1;
      } else {
        carry = 0;
      }
      // DAY & WEEKDAY
      if(carry == 1) {                          // Subtract a day and weekday if nessesary
        day = day - 1;
        _weekday = _weekday - 1;
        if(_weekday < 1) {
          _weekday = 7;
        }
      }
      // MONTH
      if(day < 1) {                             // If day hits 0 decrement month by 1 
        carry = 1;
        month = month - 1;
        if(month < 1) {                         // Check if month is 0, set to 12 accordingly
          carry = 1;
          month = 12;
        } else {
          carry = 0;
        }
        switch(month) {                         // Check which month the new month is, set the day accordingly
          case 1: 
          case 3:
          case 5:
          case 7:
          case 8:
          case 10:
          case 12:
            day = 31;
            break;
          case 4:
          case 6:
          case 9:
          case 11:
            day = 30; 
            break;
          case 2:                               // If the month is february, check for leap year, set day accordingly
            if(year % 4 == 0) {
              day = 29;
            } else { 
              day = 28;
            }
            break;
        }
      } else {
        carry = 0;
      }
      // YEAR
      if(carry == 1) {                          // If month was reduced, subtract 1 from year
        year = year - 1;
      }
    }
    
    switch(_weekday) {                          // Fill the weekday string
      case 1: 
        (void) sprintf(weekday, "Mon");
        break;
      case 2: 
        (void) sprintf(weekday, "Tue");
        break;
      case 3: 
        (void) sprintf(weekday, "Wed");
        break;
      case 4: 
        (void) sprintf(weekday, "Thu");
        break;
      case 5: 
        (void) sprintf(weekday, "Fri");
        break;
      case 6: 
        (void) sprintf(weekday, "Sat");
        break;
      case 7: 
        (void) sprintf(weekday, "Sun");
        break;
    }
    
    (void) sprintf(datum, "%s %02d.%02d.%04d", weekday, day, month, year);
    writeLine(datum, 1);
}

// ****************************************************************************
//  Read and evaluate DCF77 signal and detect events
//  Must be called by user every 10ms
//  Parameter:  Current CPU time base in milliseconds
//  Returns:    DCF77 event, i.e. second pulse, 0 or 1 data bit or minute marker
DCF77EVENT sampleSignalDCF77(int currentTime)
{   DCF77EVENT event = NODCF77EVENT;
    int signal;
    int elapsedTime = currentTime - prevTime;   // Calculate the time since the last falling Edge

    signal = readPort();
    
    if (signal == prevSignal) {                 // If the signal didnt change, set NODCF77EVENT
      event = NODCF77EVENT;
      if(elapsedTime > 3000) {                  // If there is no change for 3 expect there to be a error
        event = INVALID;
      }
      
    } else if (signal == 0 && prevSignal == 1) {      // Check for falling Edge
      if (elapsedTime <= 1100 && elapsedTime >= 900) {      // Check if 1 second +- 100ms has passed since the last falling edge, set VALIDSECOND 
        event = VALIDSECOND;
      
      } else if (elapsedTime <= 2100 && elapsedTime >= 1900) {      // Check if 2 second +- 100ms has passed since the last falling edge, set VALIDMINUTE
        event = VALIDMINUTE;
      
      } else {                                  // Everything else is INVALID
        event = INVALID;
      }
      setLED(0x02);                             // Turn on the LED on Port B.1
      prevTime = currentTime;                   // Set prevTime for the time 
      
    } else if (signal == 1 && prevSignal == 0) {      // Check for rising Edge
      if (elapsedTime <= 130 && elapsedTime >= 70) {      // Check if 100ms +- 30ms have passed since last falling edge, set VALIDZERO
        event = VALIDZERO;
      
      } else if (elapsedTime <= 230 && elapsedTime >= 170) {      // Check if 200ms +- 30ms have passed since last falling edge, set VALIDONE
        event = VALIDONE;
      
      } else {
        event = INVALID;                        // Everything else is INVALID
      }                                         // Turn off the LED on Port B.1
      clrLED(0x02);
    }
    
    prevSignal = signal;

    return event;
}

// ****************************************************************************
// Process the DCF77 events
// Contains the DCF77 state machine
// Parameter:   Result of sampleSignalDCF77 as parameter
// Returns:     -
void processEventsDCF77(DCF77EVENT event)
{
    int i = 0, parity = 0;
    int minute = 0, hour, day = 0, month = 0, year = 2000, _weekday = 0;     // Declare Variables to store recieved time and date before all checks are done; set them to 0/2000 for year
    
    switch(event) {
      case INVALID:                             // If an error occured, turn on the LED on Port B.2 and turn off the LED on Port B.3
        clrLED(0x08);                               
        setLED(0x04);
        break;
      case VALIDZERO:                           // Write a 0 in bit
        bit=0;
        break;
      case VALIDONE:                            // Write a 1 in bit
        bit=1;
        break;
      case VALIDSECOND:                         // Write the bit in the array, when VALIDSECOND; increment counter
        databits[counter]=bit;
        counter++;
        break;
      case VALIDMINUTE:                         // Once end of minute was recieved do a lot of stuff
        if (counter==58) {                      // Check if the whole minute was recieved and stored
        
          if (databits[17]==0 && databits[18]==1) {     // Check for wintertime; set hour to 1
            hour = 1;
          } else if (databits[17]==1 && databits[18]==0) {      // Check for Summertime; set hour to 0
            hour = 0;
          } else {
            error=1;
            break;
          }
          
          if (databits[20]!=1) {                // Check bit 20
            error=1;
            break;
          }
          
          parity = 0;
          for (i = 21; i <= 27; i++) {          // Add all bits in parity to get amount of 1
            parity = parity + databits[i];
          }
          if ((parity % 2) != databits[28]) {   // If even/odd parity don't matches set error to 1
            error = 1;
            break;
          }
          
          parity=0;
          for (i = 29; i <= 34; i++) {          // Add all bits in parity to get amount of 1
            parity = parity + databits[i];
          }
          if ((parity % 2) != databits[35]) {   // If even/odd parity don't matches set error to 1
            error = 1;
            break;
          }
          
          parity=0;
          for (i = 36; i <= 57; i++) {          // Add all bits in parity to get amount of 1
            parity = parity + databits[i];
          }
          if ((parity % 2) != databits[58]) {   // If even/odd parity don't matches set error to 1
            error = 1;
            break;
          }
        
          minute = minute + databits[21];       // Convert minute to decimal
          minute = minute + databits[22] * 2;
          minute = minute + databits[23] * 4;
          minute = minute + databits[24] * 8;
          minute = minute + databits[25] * 10;
          minute = minute + databits[26] * 20;
          minute = minute + databits[27] * 40;
          
          if(minute > 59) {                     // Check if recieved value is possible    
            error = 1;
            break;
          }
        
          hour = hour + databits[29];           // Convert hour to decimal
          hour = hour + databits[30] * 2;
          hour = hour + databits[31] * 4;
          hour = hour + databits[32] * 8;
          hour = hour + databits[33] * 10;
          hour = hour + databits[34] * 20;
                   
          if (hour > 23) {                      // Check if recieved value is possible
            error = 1;
            break;
          }
          
          day = day + databits[36];             // Convert day to decimal        
          day = day + databits[37] * 2;
          day = day + databits[38] * 4;
          day = day + databits[39] * 8;
          day = day + databits[40] * 10;
          day = day + databits[41] * 20;
                    
          if (day == 0 || day > 31) {           // Check if recieved value is possible
            error = 1;
            break;
          }
          
          
          _weekday = _weekday + databits[42];   // Convert weekday to decimal
          _weekday = _weekday + databits[43] * 2;
          _weekday = _weekday + databits[44] * 4;
          
          if(_weekday == 0 || _weekday > 7){    // Check if recieved value is possible
            error = 1;
            break;
          }
         
                   
          month = month + databits[45];         // Convert month to decimal
          month = month + databits[46] * 2;
          month = month + databits[47] * 4;
          month = month + databits[48] * 8;
          month = month + databits[49] * 10;
          
          if (month == 0 || month > 12) {       // Check if recieved value is possible
            error = 1;
            break;
          }
          
          year = year + databits[50];           // Convert year to decimal         
          year = year + databits[51] * 2;
          year = year + databits[52] * 4;
          year = year + databits[53] * 8;
          year = year + databits[54] * 10;
          year = year + databits[55] * 20;
          year = year + databits[56] * 40;
          year = year + databits[57] * 80;
          
          if (year > 2099) {                    // Check if recieved value is possible
            error = 1;
            break;
          }  
          
        } else {
          error = 1;
        }
        counter = 0;                            // reset counter
        
        if (error == 0) {                       // If no error occured, set dcf77 Variables to correctly recieved value; set clock; turn off the LED on Port B.2 and turn on the LED on Port B.3
          setLED(0x08);
          clrLED(0x04);
          dcf77Minute = minute;
          dcf77Hour = hour;
          dcf77Day = day;
          dcf77Weekday = _weekday;
          dcf77Month = month;
          dcf77Year = year;
          setClock((char) dcf77Hour, (char) dcf77Minute, 0);
        } else {                                 // If an error occured, turn on the LED on Port B.2 and turn off the LED on Port B.3  
          clrLED(0x08);
          setLED(0x04);
          error = 0;
        }
        break;
      case NODCF77EVENT: break;                 // If there where no dcf77 event don't do anything      
    }                           
}

