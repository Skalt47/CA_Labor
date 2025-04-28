;   Lab 1 - Preparation Task 2.3
;   Convert a signed 16-bit decimal number to a zero-terminated ASCII string
;   Main program
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   R. Keller, Jul 4, 2019
;            (based on code provided by J. Friedrich, W. Zimmermann)
;
; Modified by: Ergün Bickici & Tim Jauch

; --------------------------------------------------------------
; Exported symbols
        XDEF    Entry, main

; Imported symbols
        XREF    __SEG_END_SSTACK           ; End of stack
        XREF    decToASCII                 ; Decimal to ASCII conversion subroutine

; Include device-specific register definitions
        INCLUDE 'mc9s12dp256.inc'

; --------------------------------------------------------------
; RAM: Variable data section
.data:  SECTION
value:      DS.W    1                      ; 16-bit signed value to convert
charString: DS.B    7                      ; ASCII character array (space for sign + 5 digits + 0 termination)

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
        LDS     #__SEG_END_SSTACK            ; Initialize stack pointer
        CLI                                   ; Enable interrupts (required for debugger)

        ; Prepare test value and output buffer
        LDX     #charString                  ; Load address of output buffer
        MOVW    #-256, value                 ; Load example value (-256) into 'value'
        LDD     value                        ; Load value into D register
        JSR     decToASCII                   ; Convert value to ASCII string

; --------------------------------------------------------------
; Infinite loop to keep program running
loop:
        BRA     loop