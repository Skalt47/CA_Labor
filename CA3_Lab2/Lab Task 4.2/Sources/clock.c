/*   Lab Task 4.2
     Created by: Ergün Bickici & Tim Jauch 
*/

#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"


// Public interface function: initClock initialize global variables for time (called once)
// Parameter: -
// Return: -
// Registers: -

unsigned char hours;
unsigned char minutes;
unsigned char seconds;

void initClock(void) {
    hours = 11;
    minutes = 59;
    seconds = 30;
}

// Public interface function: incrementHours increments Hours (method call)
// Parameter: -
// Return: -
// Registers: -

void incrementHours(void) {
    hours++;
    if (hours > 23) {
        hours = 0;
    }
}

// Public interface function: incrementMinutes increments Minutes (method call)
// Parameter: -
// Return: -
// Registers: -

void incrementMinutes(void) {
    minutes++;
    if (minutes > 59) {
        incrementHours();
        minutes = 0;
    }
}

// Public interface function: incrementSeconds increments seconds (method call)
// Parameter: -
// Return: -
// Registers: -

void incrementSeconds(void) {
    seconds++;
    if (seconds > 59) {
        incrementMinutes();
        seconds = 0;
    }
}


// Public interface function: tickClock call incrementSeconds (with clock event)
// Parameter: -
// Return: -
// Registers: -

void tickClock(void) {
  incrementSeconds();
}