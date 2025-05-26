/*  Lab 2 - Main C file for Clock program

    Computerarchitektur 3
    (C) 2018 J. Friedrich, W. Zimmermann
    Hochschule Esslingen

    Author:  W.Zimmermann, July 19, 2017
    Modified by: Ergün Bickici & Tim Jauch 
*/


#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

#define SELECT12HOURS                           // To access the 24-hour view of the clock comment this line out


// PLEASE NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!:
// Files lcd.asm and ticker.asm do contain SOFTWARE BUGS. Please overwrite them
// with the lcd.asm file, which you bug fixed in lab 1, and with file ticker.asm
// which you bug fixed in prep task 2.1 of this lab 2.
//
// To use decToASCII you must insert file decToASCII from the first lab into
// this project
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


// ****************************************************************************
// Function prototype(s)
// Note: Only void Fcn(void) assembler functions can be called from C directly.
//       For non-void functions a C wrapper function is required.
void initTicker(void);

// Prototypes and wrapper functions for dec2ASCII (from lab 1)
void decToASCII(void);

void delay(unsigned int ms){
  unsigned int i,j;
  for(i = 0; i < ms; i++)
    for(j = 0; j < 4000; j++);
}

// Public interface function: decToASCII_Wrapper wrapper function for decToASCII (methode call)
// Parameter: char pointer to destination for convertet string, int number to convert to string
// Return: -
// Registers: -

void decToASCII_Wrapper(char *txt, int val)
{   asm
    {  	LDX txt
        LDD val
        JSR decToASCII
    }
}
    

// Prototypes and wrapper functions for LCD driver (from lab 1)
void initLCD(void);
void writeLine(void);

// Public interface function: WriteLine_Wrapper wrapper function for writeLine (methode call)
// Parameter: char pointer to location of LCD print, int define LCD line
// Return: -
// Registers: -

void WriteLine_Wrapper(char *text, char line)
{   asm
    {	LDX  text
        LDAB line
        JSR  writeLine
    }
}

// ****************************************************************************

// Public interface function: initLED_C initialize port of output for LEDs und LCD (called once)
// Parameter: -
// Return: -
// Registers: -

void initLED_C(void)
{   
    //--- Initialize LEDs, deactivate seven segment display -----------------------
    DDRJ = DDRJ |  0x02;        // Bit Set:   Port J.1 as output
    PTJ  = PTJ  & ~0x02;        // Bit Clear: J.1=0 --> Activate LEDs
    DDRB = 0xFF;                // Port B as outputs
#ifndef sevenSegmentDisplay     // Disable seven segment display if not used
    DDRP = 0x0F;                // Port P.3..0 as outputs (seven segment display control)
    PTP  = 0x0F;                // Turn off seven segment display
#endif
}


// Public interface function: toggleLED_C switch LED (methode call)
// Parameter: char bitmask toggle LEDs
// Return: -
// Registers: -

void toggleLED_C(char leds) 
{
    PORTB = PORTB ^ leds;
}

// ****************************************************************************

// Public interface function: incrementCounter move to next field in array with strings for line 0 LCD (methode call)
// Parameter: unsigned char pointer, unsigned char max value for counter
// Return: -
// Registers: -

void incrementCounter(unsigned char *counter, unsigned char max) {
    if (*counter < max) {
        (*counter)++;
    } else {
        *counter = 0;
    }
}

// ****************************************************************************
extern unsigned char hours;
extern unsigned char minutes;
extern unsigned char seconds;

void initClock(void);
void incrementHours(void);
void incrementMinutes(void);
void incrementSeconds(void);
void tickClock(void);

// ****************************************************************************
extern int temperature;

void initThermometer(void);

// ****************************************************************************

// Global variables
unsigned char clockEvent = 0;
unsigned char mode = 0;
unsigned char counter = 0;
unsigned char end;
unsigned char i;


// Public interface function: isButtonPressed counting counters (methode call)
// Parameter: char button pressed button
// Return: char button on/off
// Registers: -

char isButtonPressed(char btn)
{
#ifdef _HCS12_SERIALMON
    return !btn;
#else
    return btn;
#endif 
}

unsigned char line1Counter = 0;
char *line1[] = {"Erguen Bickici", "Tim Jauch", "(c) IT SS 2025"};


// Public interface function: WriteLine1_C print line 0 in LCD (methode call)
// Parameter: -
// Return: -
// Registers: -

void WriteLine1_C() {
    WriteLine_Wrapper(line1[line1Counter], 0);
    incrementCounter(&line1Counter, 2);
}

char line2[17];




// Public interface function: WriteLine2_C preparing time/temperature to be printed in LCD (methode call)
// Parameter: -
// Return: -
// Registers: -

void WriteLine2_C() {
#ifdef SELECT12HOURS
    if (hours == 0 || hours == 12) {
        decToASCII_Wrapper(line2, 12);
    } else if (hours - 12 < 0) {
        decToASCII_Wrapper(line2, hours);
    } else {
        decToASCII_Wrapper(line2, hours - 12);
    }
#else
    decToASCII_Wrapper(line2, hours);
#endif
    line2[2] = ':';
    if (line2[1] == '\0') {
        line2[1] = line2[0];
        line2[0] = '0';
    }
    line2[5] = ':';
    decToASCII_Wrapper(line2 + 3, minutes);
    if (line2[4] == '\0') {
        line2[4] = line2[3];
        line2[3] = '0';
    }
    line2[5] = ':';
    decToASCII_Wrapper(line2 + 6, seconds);
    if (line2[7] == '\0') {
        line2[7] = line2[6];
        line2[6] = '0';
    }

#ifdef SELECT12HOURS
    if (hours - 12 < 0) {
        line2[8] = 'a';
    } else {
        line2[8] = 'p';
    }
    line2[9] = 'm';
#else
    line2[8] = ' ';
    line2[9] = ' ';
#endif

    decToASCII_Wrapper(line2 + 10, temperature);
    
    for (end = 10; line2[end] != '\0'; end++) {}
    
    for (i = 14; i > 9; i--) {
        if (end > 9) {
            line2[i] = line2[end];
            end--;
        } else {
            line2[i] = ' ';
        }
    }

    line2[14] = 0xDF;                 // for Simulator this needs to be changed, so the degree symbol is displayed properly
    line2[15] = 'C';
    line2[16] = '\0';

    WriteLine_Wrapper(line2, 1);
}

// ****************************************************************************
void main(void) 
{   
    EnableInterrupts;                   // Global interrupt enable

    initLED_C();                    	// Initialize the LEDs
    initLCD();                    		// Initialize the LCD

    initTicker();                       // Initialize the time ticker
    initClock();                        // Initialize the clock
    initThermometer();                  // Initialize the thermometer

    WriteLine1_C();                     // Write first line
    WriteLine2_C();                     // Write second line

    for(;;)                                     // Endless loop
    {   
        if (isButtonPressed(PTH_PTH0)) 
        {
            mode = !mode;
            toggleLED_C(0x80);             // Toggle left most LED
            while(isButtonPressed(PTH_PTH0));
            delay(200);
        }

        if (mode == 1) {
            if (isButtonPressed(PTH_PTH1)) {
                incrementHours();
                WriteLine2_C();
                delay(200); 
            }
            if (isButtonPressed(PTH_PTH2)) {
                incrementMinutes();
                WriteLine2_C();
                delay(200);  
            }
            if (isButtonPressed(PTH_PTH3)) {
                incrementSeconds();
                WriteLine2_C();
                delay(200);  
            }
        }

        if (clockEvent)
    	  {   
            clockEvent = 0;
            toggleLED_C(0x01);                 // Toggle right most LED
            if(mode != 1){
              tickClock();
              WriteLine2_C();
            }

            if (counter == 9) {
                WriteLine1_C();
            }

            incrementCounter(&counter, 9);
    	}
    }
}
