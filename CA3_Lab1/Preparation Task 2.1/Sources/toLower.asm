; Lab 1 - Preparation Task 2.1
; Convert a zero-terminated ASCII string to lower characters
;
; Computerarchitektur
; (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
; Hochschule Esslingen
;
; Modified by: Ergün Bickici & Tim Jauch

; --------------------------------------------------------------
; Exported symbols
        XDEF    toLower

; Include device-specific register definitions
        INCLUDE 'mc9s12dp256.inc'

; --------------------------------------------------------------
; RAM: Variable data section
.data:  SECTION

; --------------------------------------------------------------
; ROM: Constant data section
.const: SECTION

; --------------------------------------------------------------
; ROM: Code section
.init:  SECTION

; --------------------------------------------------------------
; Public interface function: toLower
; Purpose: Convert a zero-terminated string from uppercase to lowercase in RAM
; Parameters:
;   D ... pointer to the first character of the string
; Returns: -
; Registers modified: A, B, X, Y
; Error checks: None
; Notes:
; - Converts only characters 'A'..'Z' to 'a'..'z'.
; - Other characters are unchanged.

toLower:
        PSHD                                 ; Save D register
        PSHX                                 ; Save X register
        PSHY                                 ; Save Y register

        ; Transfer pointer from D to X
        TFR     D, X

; --------------------------------------------------------------
; Loop through each character and convert if uppercase
toLower_loop:
        LDAB    0, X                         ; Load character
        TSTB                                 ; Check if end of string (0x00)
        BEQ     toLower_end                  ; If end of string, exit

        CMPB    #'A'                         ; Compare to 'A'
        BLO     toLower_next                 ; If lower, skip
        CMPB    #'Z'                         ; Compare to 'Z'
        BHI     toLower_next                 ; If higher, skip

        ADDB    #32                          ; Convert uppercase to lowercase
        STAB    0, X                         ; Store modified character

toLower_next:
        INX                                  ; Advance to next character
        BRA     toLower_loop                 ; Repeat loop

; --------------------------------------------------------------
; Restore registers and return
toLower_end:
        PULY                                 ; Restore Y register
        PULX                                 ; Restore X register
        PULD                                 ; Restore D register
        RTS                                  ; Return from subroutine
