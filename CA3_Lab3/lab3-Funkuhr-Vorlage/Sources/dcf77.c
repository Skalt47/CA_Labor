/*  Radio signal clock - DCF77 Module

    Computerarchitektur 3
    (C) 2018 J. Friedrich, W. Zimmermann Hochschule Esslingen

    Author:   W.Zimmermann, Jun  10, 2016
    Modified: Ergün Bickici & Tim Jauch
*/

#include <hidef.h>                   // Common defines
#include <mc9s12dp256.h>             // CPU specific defines
#include <stdio.h>

#include "dcf77.h"
#include "led.h"
#include "clock.h"
#include "lcd.h"

// defines
#define LED0 0x01
#define LED1 0x02
#define LED2 0x04
#define LED3 0x08

// Global variable holding the last DCF77 event
DCF77EVENT dcf77Event = NODCF77EVENT;
int dataOK = 0;
char lastSig = 0;
int Tlow = 0;
int Tpulse = 0;
int Tcur = 0;
int timedata[60];
int secCounter = 0;
const char dow[8][4] = { {"ERR"}, {"Mon"}, {"Tue"}, {"Wed"}, {"Thu"}, {"Fri"}, {"Sat"}, {"Sun"} };
unsigned char us_on = 0;

// Modul internal global variables
static int dcf77Dow = 6, dcf77Year = 2400, dcf77Month = 3, dcf77Day = 1;
static int dcf77Hour = 0, dcf77Minute = 0;   // DCF77 Date and time as integer values

// Prototypes for simulation
void initializePortSim(void);
char readPortSim(void);

// Prototypes for US/DE adjustment
static int isLeap(int year);
static int daysInMonth(int month, int year);
static void adjustDate(int *day, int *month, int *year, int deltaDays);
void USDE(void);

// ****************************************************************************
// Initalize the hardware port on which the DCF77 signal is connected as input
// Parameter:   -
// Returns:     -
void initializePort(void) {
    DDRH = 0x00; // Port H as input
    PIEH = 0x00; // no Interrupts
}

// ****************************************************************************
// Read the hardware port on which the DCF77 signal is connected as input
// Parameter:   -
// Returns:     0 if signal is Low, >0 if signal is High
char readPort(void) {
    return (PTH & 0x01) ? 1 : 0;
}

// ****************************************************************************
// Initialize DCF77 module
// Called once before using the module
// Parameter:   -
// Returns:     -
void initDCF77(void) {
    setClock((char)dcf77Hour, (char)dcf77Minute, 0);
    displayDateDcf77();
    // initializePortSim(); // for Simulation  <-------------------------------------------------
    initializePort();      // for Hardware     <-------------------------------------------------
}

// ****************************************************************************
// Display the date derived from the DCF77 signal on the LCD display, line 1
// Parameter:   -
// Returns:     -
void displayDateDcf77(void) {
    char date[32];
    sprintf(date, "%s: %02d.%02d.%04d", dow[dcf77Dow], dcf77Day, dcf77Month, dcf77Year);
    writeLine(date, 1);
}

//****************************************************************************
//  Read and evaluate DCF77 signal and detect events
//  Must be called by user every 10ms
//  Parameter:  Current CPU time base in milliseconds
//  Returns:    DCF77 event, i.e. second pulse, 0 or 1 data bit or minute marker
DCF77EVENT sampleSignalDCF77(int currentTime) {
    DCF77EVENT event = NODCF77EVENT;
    // char signal = readPortSim();  // for Simulation <-----------------------------------------
    char signal = readPort(); // for Hardware  <-------------------------------------------------

    if (signal != lastSig && signal == 0) {    // falling flank
        Tpulse = currentTime - Tcur;
        Tcur = currentTime;
        Tlow = 0;
        setLED(LED1);
        if (Tpulse >= 900 && Tpulse <= 1100)      event = VALIDSECOND;
        else if (Tpulse >= 1900 && Tpulse <= 2100) event = VALIDMINUTE;
        else                                     event = INVALID;
    }
    else if (signal != lastSig && signal > 0) {
        Tlow = currentTime - Tcur;
        clrLED(LED1);
        if (Tlow >= 70 && Tlow <= 130)          event = VALIDZERO;
        else if (Tlow >= 170 && Tlow <= 230)     event = VALIDONE;
        else                                    event = INVALID;
    }
    lastSig = signal;
    return event;
}

// ****************************************************************************
// Process the DCF77 events
// Contains the DCF77 state machine
// Parameter:   Result of sampleSignalDCF77 as parameter
// Returns:     -
void processEventsDCF77(DCF77EVENT event) {
    if (event == VALIDONE)      timedata[secCounter] = 1;
    else if (event == VALIDZERO)timedata[secCounter] = 0;
    else if (event == VALIDSECOND) secCounter++;
    else if (event == INVALID)    timedata[secCounter] = -1;
    else if (event == VALIDMINUTE) {
        secCounter = 0;
        eventMinute();
        if (dataOK) {
            if (us_on) USDE();
            setClock((char)dcf77Hour, (char)dcf77Minute, 0);
            displayDateDcf77();
        }
    }
}

// ****************************************************************************
// Handles a VALIDMINUTE event
// Parameter:   -
// Returns:     -
void eventMinute(void) {
    int bitValue[] = {1,2,4,8,10,20,40,80};
    int i, cnt = 0;
    int year=2000, month=0, dow=0, day=0, hours=0, min=0;
    int parMin=0, parHrs=0, parDat=0;

    // Year
    for (i=50; i<=57; i++) {
        if (timedata[i]) year += bitValue[cnt];
        cnt++;
    }
    cnt = 0;
    // Month
    for (i=45; i<=49; i++) {
        if (timedata[i]) month += bitValue[cnt];
        cnt++;
    }
    cnt = 0;
    if (month < 1 || month > 12) { dataOK = -1; setLED(LED2); return; }
    // DayOfWeek
    for (i=42; i<=44; i++) {
        if (timedata[i]) dow += bitValue[cnt];
        cnt++;
    }
    cnt = 0;
    if (dow < 1 || dow > 7) { dataOK = -1; setLED(LED2); return; }
    // Day
    for (i=36; i<=41; i++) {
        if (timedata[i]) day += bitValue[cnt];
        cnt++;
    }
    cnt = 0;
    if (day < 1 || day > 31) { dataOK = -1; setLED(LED2); return; }
    // Hours
    for (i=29; i<=34; i++) {
        if (timedata[i]) hours += bitValue[cnt];
        cnt++;
    }
    cnt = 0;
    if (hours < 0 || hours > 23) { dataOK = -1; setLED(LED2); return; }
    // Minutes
    for (i=21; i<=27; i++) {
        if (timedata[i]) min += bitValue[cnt];
        cnt++;
    }
    cnt = 0;
    if (min < 0 || min > 59) { dataOK = -1; setLED(LED2); return; }

    // Parity
    for (i=21; i<=27; i++) parMin += timedata[i];
    for (i=29; i<=34; i++) parHrs += timedata[i];
    for (i=36; i<=57; i++) parDat += timedata[i];

    if ((parMin % 2) == timedata[28] && (parHrs % 2) == timedata[35] && (parDat % 2) == timedata[58]) {
        dcf77Year = year;
        dcf77Month = month;
        dcf77Dow = dow;
        dcf77Day = day;
        dcf77Hour = hours;
        dcf77Minute = min;
        clrLED(LED2);
        setLED(LED3);
        dataOK = 1;
    } else {
        clrLED(LED3);
        setLED(LED2);
        dataOK = 0;
    }
}

// ****************************************************************************
// Check if H.3 is pressed
// Parameter:   -
// Returns:     -
void USDE_Pressed() {
    if ((~PTH & 0x08)) {  // for Simulation do PTH, for Hardware do ~PTH
        us_on = !us_on;
        USDE();
        setClock((char)dcf77Hour, (char)dcf77Minute, (char)secCounter);
        displayTimeClock();
        displayDateDcf77();
    }
}

// ****************************************************************************
// Checking leap year
// Parameter:  year — the year to test
// Returns:    1 if year is divisible by 4 and (not by 100 unless also divisible by 400), 0 otherwise
static int isLeap(int year) {
    return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
}

// ****************************************************************************
// Days in month
// Parameter:  month — month number (1–12)
//             year  — year for leap-year determination
// Returns:    number of days in the given month (Feb = 29 in leap years, else 28; all other months as per the mdays table)
static int daysInMonth(int month, int year) {
    static const int mdays[12] = {31,28,31,30,31,30,31,31,30,31,30,31};
    if (month == 2) {
        return isLeap(year) ? 29 : 28;
    }
    return mdays[month-1];
}

// ****************************************************************************
// Adjust date ± deltaDays
// Parameter:  *day       — pointer to current day of month
//             *month     — pointer to current month (1–12)
//             *year      — pointer to current year
//             deltaDays  — number of days to add (can be negative or positive)
// Returns:    void (updates *day, *month, *year in place; wraps month/year boundaries as needed)
static void adjustDate(int *day, int *month, int *year, int deltaDays) {
    *day += deltaDays;
    if (*day < 1) {
        (*month)--;
        if (*month < 1) { *month = 12; (*year)--; }
        *day = daysInMonth(*month, *year);
    } else if (*day > daysInMonth(*month, *year)) {
        *day = 1;
        (*month)++;
        if (*month > 12) { *month = 1; (*year)++; }
    }
}

// ****************************************************************************
// Change US and DE Time
// Check if H.3 is pressed to do so
// Parameter:   -
// Returns:     -
void USDE(void) {
    int offset = us_on ? -6 : +6;
    int newHour = dcf77Hour + offset;
    int dayOffset = 0;

    if (newHour < 0) {
        newHour += 24;
        dayOffset = -1;
    } else if (newHour >= 24) {
        newHour -= 24;
        dayOffset = +1;
    }
    dcf77Hour = newHour;

    if (dayOffset != 0) {
        adjustDate(&dcf77Day, &dcf77Month, &dcf77Year, dayOffset);
        // Weekday 1=Mo … 7=So
        dcf77Dow = ((dcf77Dow - 1 + dayOffset + 7) % 7) + 1;
    }
}
