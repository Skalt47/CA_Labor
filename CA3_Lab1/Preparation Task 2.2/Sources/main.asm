;   Lab 1 - Preparation Task 2.2
;   Convert a 16-bit hexadecimal number to a zero-terminated ASCII string
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
        XREF    hexToASCII                 ; Hex to ASCII conversion subroutine

; Include device-specific register definitions
        INCLUDE 'mc9s12dp256.inc'

; --------------------------------------------------------------
; RAM: Variable data section
.data:  SECTION
value:      DS.W    1                      ; 16-bit value to convert
charString: DS.B    7                      ; ASCII character array (0x____0 format)

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

        ; Prepare input value and output buffer
        LDX     #charString                  ; Load address of output buffer
        MOVW    #$F018, value                ; Load example value (0xF018) into 'value'
        LDD     value                        ; Load value into D register
        JSR     hexToASCII                   ; Convert value to ASCII string

; --------------------------------------------------------------
; Infinite loop to keep program running
loop:
        BRA     loop