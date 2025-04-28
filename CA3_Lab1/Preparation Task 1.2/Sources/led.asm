; Lab 1 - Preparation Task 1.2
; LED control functions: initialize, set, get, toggle
;
; Computerarchitektur
; (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
; Hochschule Esslingen
;
; Modified by: Ergün Bickici & Tim Jauch

; --------------------------------------------------------------
; Exported symbols
        XDEF    initLED, setLED, getLED, toggleLED

; --------------------------------------------------------------
; Include device-specific register definitions
        INCLUDE 'mc9s12dp256.inc'

; --------------------------------------------------------------
; ROM: Code section
.init:  SECTION

; --------------------------------------------------------------
; Public interface function: initLED
; Purpose: Initialize PORTB as output to control LEDs
; Parameter: -
; Returns: -
; Registers modified: A
; Error checks: None
initLED:
        BSET    DDRJ, #2                    ; Set Port J.1 as output (activate LEDs control)
        BCLR    PTJ,  #2                    ; Clear Port J.1 to enable LEDs

        ; (Seven segment display control skipped)

        MOVB    #$FF, DDRB                  ; Set all PORTB pins as outputs
        MOVB    #0, PORTB                   ; Turn off all LEDs
        RTS
        MOVB    #0, PORTB                   ; Turn off all LEDs
        RTS

; --------------------------------------------------------------
; Public interface function: setLED
; Purpose: Set the LED output value according to register B
; Parameter: B = value to output on LEDs
; Returns: -
; Registers modified: -
; Error checks: None
setLED:
        STAB    PORTB                       ; Write B to PORTB (LEDs)
        RTS

; --------------------------------------------------------------
; Public interface function: getLED
; Purpose: Read the current state of LEDs
; Parameter: -
; Returns: B = LED state read from PORTB
; Registers modified: B
; Error checks: None
getLED:
        LDAB    PORTB                       ; Load PORTB into B
        RTS

; --------------------------------------------------------------
; Public interface function: toggleLED
; Purpose: Invert the LED output (toggle all LEDs)
; Parameter: -
; Returns: -
; Registers modified: B
; Error checks: None
toggleLED:
        EORB    PORTB                       ; XOR B with PORTB (toggle LEDs)
        STAB    PORTB
        RTS
