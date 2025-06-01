/*   Lab Task 4.2
     Created by: Ergün Bickici & Tim Jauch 
*/

#include <hidef.h>                              // Common defines
#include <mc9s12dp256.h>                        // CPU specific defines

#pragma LINK_INFO DERIVATIVE "mc9s12dp256b"

int temperature = 0;      // Measurement value
unsigned int raw = 0;

void convertTemperature(void);


// Public interface function: interrupt service, messure momentaneus temperature (called with interrupt vector 22)
// Parameter: -
// Return: -
// Registers: -

// --- ADC interrupt service routine -----------------------
void interrupt 22 adcISR(void)
{  // Read the result registers and compute average of 4 measurements
#ifdef _HCS12_SERIALMON
    raw = (ATD0DR0 + ATD0DR1 + ATD0DR2 + ATD0DR3) >> 2;
    convertTemperature(); 
#else
    temperature = -1;
#endif

    ATD0CTL2 = ATD0CTL2 | 0x01;  // Reset interrupt flag (bit 0 in ATD0CTL2)
    ATD0CTL5 = 0b10000111;       // Start next measurement on single channel 7
}

// Public interface function: initThermometer initialize analog input (called once)
// Parameter: -
// Return: -
// Registers: -

void initThermometer(void)
{
  ATD0CTL2 = 0b11000010;// Enable ATD0, enable interrupt
  ATD0CTL3 = 0b00100000;// Sequence: 4 measurements
  ATD0CTL4 = 0b00000101;// 10bit, 2MHz ATD0 clock

  ATD0CTL5 = 0b10000111;// Start first measurement on single channel 7
}

// Public interface function:convertTemperature convert analog value to degree celsius 
// Parameter: -
// Return: -
// Registers: -

void convertTemperature(void) {
    asm {
      LDY raw           // averaged ADC reading (0...1023)
    
      LDY #100          // multiply by 100
      EMULS             // signed multiply by 16, so result is 32-bit that end up in D (low half) and Y (high half)
      LDX   #1023
      EDIV              // Dividing the 32-bit by 1023 rescales back down between 0...100
      TFR   Y, D
      SUBD  #30         // Subtracting with 30, cause the temp range is -30...+70°C
      
      STD temperature
    }
}
