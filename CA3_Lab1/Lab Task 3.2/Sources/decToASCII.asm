;   Lab 1 - Preparation Task 2.3
;   Convert a signed 16-bit decimal number to an ASCII string
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
        XDEF    decToASCII

; --------------------------------------------------------------
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
; Public interface function: decToASCII
; Purpose: Convert a signed 16-bit value (in register D) to a decimal ASCII string.
; Parameters:
;   D ... Signed 16-bit integer value
;   X ... Pointer to destination buffer (at least 7 bytes)
; Returns: -
; Registers modified: A, B, D, X, Y
; Error checks: None
; Notes:
; - The resulting string format is: sign + 5 digits + NUL terminator

decToASCII:
        PSHY                                ; Save registers
        PSHX
        PSHD

        ; Check if value is zero or negative
        CPD     #0
        BGT     positive
        MOVB    #'-', 0,X                   ; Store '-' for negative values

        ; Negate D (two's complement)
        COMA
        COMB
        ADDD    #1
        BRA     continue

positive:
        MOVB    #' ', 0,X                   ; Store ' ' (blank) for positive values

continue:
        TFR     X, Y                        ; Save start address of string
        MOVB    #0, 6,Y                     ; Add terminating zero at end

        ; Divide by 10000
        LDX     #10000
        IDIV
        PSHD
        TFR     X, D
        ADDD    #'0'
        STAB    1,Y

        ; Divide by 1000
        LDX     #1000
        PULD
        IDIV
        PSHD
        TFR     X, D
        ADDD    #'0'
        STAB    2,Y

        ; Divide by 100
        LDX     #100
        PULD
        IDIV
        PSHD
        TFR     X, D
        ADDD    #'0'
        STAB    3,Y

        ; Divide by 10
        LDX     #10
        PULD
        IDIV
        PSHD
        TFR     X, D
        ADDD    #'0'
        STAB    4,Y

        ; Last digit (units place)
        PULD
        ADDD    #'0'
        STAB    5,Y

        ; Restore all saved registers
        PULD
        PULX
        PULY
        RTS