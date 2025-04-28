;   Lab Task 3.2
;   Labor 1 - Test program for LCD driver
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   	   J.Friedrich, W. Zimmermann
;   Last Modified: R. Keller, August 2022
;
; Modified by: Ergün Bickici & Tim Jauch


; --------------------------------------------------------------
; Exported symbols
        XDEF    Entry, main
        XDEF    initButtons
        XDEF    checkButtons

; Imported symbols
        XREF    __SEG_END_SSTACK              ; End of stack
        XREF    initLCD, writeLine, delay_10ms
        XREF    decToASCII, hexToASCII
        XREF    initLED, setLED
        XREF    delay_0_5sec

; Include device-specific register definitions
        INCLUDE 'mc9s12dp256.inc'

; --------------------------------------------------------------
; RAM: Variable data section
.data:  SECTION
Vtext:  DS.B    17                             ; Buffer for ASCII text (max 16 characters + null)

; --------------------------------------------------------------
; ROM: Constant data section
.const: SECTION

; --------------------------------------------------------------
; ROM: Code section
.init:  SECTION

; --------------------------------------------------------------
; Main program
main:
Entry:
        LDS     #__SEG_END_SSTACK               ; Initialize stack pointer
        CLI                                     ; Enable interrupts (required for debugger)

        ; Initialize peripherals
        JSR     initLED
        JSR     initLCD
        JSR     initButtons                     ; Configure Port H for button input

        ; Initialize counter
        LDD     #0

; --------------------------------------------------------------
; Main loop
loop:
        ; Display decimal number on LCD line 0
        LDX     #Vtext
        JSR     decToASCII
        PSHD
        LDAB    #0
        JSR     writeLine
        PULD

        ; Display hexadecimal number on LCD line 1
        LDX     #Vtext
        JSR     hexToASCII
        PSHD
        LDAB    #1
        JSR     writeLine
        PULD

        ; Output value to LEDs
        JSR     setLED

        ; Delay ~0.5 seconds
        JSR     delay_0_5sec

        ; Check button inputs
        JSR     checkButtons

        BRA     loop

; --------------------------------------------------------------
; Subroutine: initButtons
; Purpose: Configure Port H as input for buttons
; Parameters: -
; Returns: -
; Registers modified: -
; Error checks: None
initButtons:
        CLR     DDRH                             ; Configure Port H pins as input
        CLR     PTH                              ; Clear Port H output latch (optional)
        RTS

; --------------------------------------------------------------
; Subroutine: checkButtons
; Purpose: Read button inputs and adjust counter accordingly
; Parameters: -
; Returns: -
; Registers modified: D
; Error checks: None
checkButtons:
  IFDEF SIMULATOR
        BRSET   PTH, #$01, inc16
        BRSET   PTH, #$02, inc10
        BRSET   PTH, #$04, dec16
        BRSET   PTH, #$08, dec10
        BRA     inc
  ELSE
        BRCLR   PTH, #$01, inc16
        BRCLR   PTH, #$02, inc10
        BRCLR   PTH, #$04, dec16
        BRCLR   PTH, #$08, dec10
        BRA     inc
  ENDIF

; --------------------------------------------------------------
; Button action subroutines
inc16:
        ADDD    #16
        RTS

inc10:
        ADDD    #10
        RTS

dec16:
        SUBD    #16
        RTS

dec10:
        SUBD    #10
        RTS

inc:
        ADDD    #1
        RTS

; --------------------------------------------------------------
; Infinite loop (should never reach here)
back:
        BRA     back