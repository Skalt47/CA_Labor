; Labor 1 - Preparation Task 2.1
; Convert a zero-terminated ASCII string to lower characters
;
; Computerarchitektur
; (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
; Hochschule Esslingen
;
; Modified by: Ergün Bickici & Tim Jauch

; --------------------------------------------------------------
; Exported symbols
        XDEF    Entry, main

; Imported symbols
        XREF    __SEG_END_SSTACK           ; End of stack
        XREF    toLower

; Include device-specific register definitions
        INCLUDE 'mc9s12dp256.inc'

; --------------------------------------------------------------
; RAM: Variable data section
.data:  SECTION
Vtext:  DS.B    80                          ; String array (in RAM)

; --------------------------------------------------------------
; ROM: Constant data section
.const: SECTION
Ctext:  DC.B    "Test 12345 *!? ABCDE abcde zZ", 0 ; Constant string, zero-terminated

; --------------------------------------------------------------
; ROM: Code section
.init:  SECTION

; --------------------------------------------------------------
; Main program
main:
Entry:
        LDS     #__SEG_END_SSTACK             ; Initialize stack pointer
        CLI                                   ; Enable interrupts (required for debugger)

        ; Copy constant string from ROM (Ctext) to RAM (Vtext)
        LDX     #Ctext
        LDY     #Vtext
        JSR     STRCPY

        ; Convert string in Vtext to lowercase
        LDD     #Vtext
        JSR     toLower

; --------------------------------------------------------------
; Infinite loop to keep program running
loop:
        BRA     loop

; --------------------------------------------------------------
; Subroutine STRCPY
; Purpose: Copy a zero-terminated string from X (source) to Y (destination)
; Parameters: 
;   X ... pointer to source string (ROM)
;   Y ... pointer to destination string (RAM)
; Returns: -
; Registers modified: A, B, X, Y
; Error checks: None
STRCPY:
        MOVB    0,X, 1,Y+                    ; Copy character from source to destination
        TST     1,X+                         ; Test next source character
        BNE     STRCPY                       ; If not end of string, continue copying
        RTS                                  ; Return from subroutine
