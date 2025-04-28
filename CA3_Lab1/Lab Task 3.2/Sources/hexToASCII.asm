;   Lab 1 - Preparation Task 2.2
;   Convert a 16-bit hexadecimal number to an ASCII string
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   R. Keller, HS-Esslingen
;            (based on code provided by J. Friedrich, W. Zimmermann)
;
; Modified by: Ergün Bickici & Tim Jauch

; --------------------------------------------------------------
; Exported symbols
        XDEF    hexToASCII

; --------------------------------------------------------------
; Include device-specific register definitions
        INCLUDE 'mc9s12dp256.inc'

; --------------------------------------------------------------
; RAM: Variable data section
.data:  SECTION

; --------------------------------------------------------------
; ROM: Constant data section
.const: SECTION
H2A:    DC.B    "0123456789ABCDEF"            ; Lookup table for hexadecimal digits

; --------------------------------------------------------------
; ROM: Code section
.init:  SECTION

; --------------------------------------------------------------
; Public interface function: hexToASCII
; Purpose: Convert a 16-bit hexadecimal value into an ASCII string ("0x____0").
; Parameters:
;   D ... 16-bit value to convert
;   X ... pointer to destination string (at least 7 bytes)
; Returns: -
; Registers modified: A, B, D, X, Y
; Error checks: None

hexToASCII:
        PSHY                                 ; Save Y register
        PSHX                                 ; Save X register
        PSHD                                 ; Save D register

        ; Initialize the output buffer with "0x"
        MOVB    #'0', 0, X
        MOVB    #'x', 1, X
        MOVB    #0, 6, X

; --------------------------------------------------------------
; Extract first (highest) hex digit
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD                                ; Logical shift right D 12 times
        ANDB    #$0F                        ; Mask lower nibble
        TFR     B, Y                        ; Transfer to Y for lookup
        LDD     H2A, Y                      ; Load ASCII character from table
        STAA    2, X                        ; Store to output buffer
        PULD                                ; Restore D register

; --------------------------------------------------------------
; Extract second hex digit
        PSHD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD                                ; Logical shift right D 8 times
        ANDB    #$0F
        TFR     B, Y
        LDD     H2A, Y
        STAA    3, X
        PULD

; --------------------------------------------------------------
; Extract third hex digit
        PSHD
        LSRD
        LSRD
        LSRD
        LSRD                                ; Logical shift right D 4 times
        ANDB    #$0F
        TFR     B, Y
        LDD     H2A, Y
        STAA    4, X
        PULD

; --------------------------------------------------------------
; Extract fourth (lowest) hex digit
        PSHD
        ANDB    #$0F
        TFR     B, Y
        LDD     H2A, Y
        STAA    5, X
        PULD

; --------------------------------------------------------------
; Restore registers and return
        PULX
        PULY
        RTS