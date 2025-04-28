; Lab 1 - Preparation Task 2.3
; Convert a signed 16-bit decimal number to an ASCII string
;
; Computerarchitektur
; (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
; Hochschule Esslingen
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
; - The resulting string format is: [sign][5 digits][NUL terminator]
; - Example:  -123 ? "-00123"

decToASCII:
        PSHY                                ; Save Y register
        PSHX                                ; Save X register
        PSHD                                ; Save D register

        ; --------------------------------------------------------------
        ; Step 1: Handle sign
        ; If D < 0, store '-' and negate the number
        ; If D >= 0, store space ' ' (positive numbers are not shown with '+')
        CPD     #0
        BGT     positive                    ; If D > 0, jump to positive
        MOVB    #'-', 0,X                   ; Store minus sign at first byte

        ; Negate D using two's complement (invert bits + add 1)
        COMA
        COMB
        ADDD    #1
        BRA     continue

positive:
        MOVB    #' ', 0,X                   ; Store space for positive numbers

continue:
        ; Save pointer to string start for further storage
        TFR     X, Y                        ; Copy X to Y
        MOVB    #0, 6,Y                     ; Set null terminator at position 6

        ; --------------------------------------------------------------
        ; Step 2: Conversion to ASCII characters
        ; We divide the number step-by-step:
        ; - Divide by 10000 -> first digit
        ; - Divide by 1000  -> second digit
        ; - Divide by 100   -> third digit
        ; - Divide by 10    -> fourth digit
        ; - Remaining units place -> fifth digit
        ;
        ; Why this approach?
        ; - Because IDIV computes quotient and remainder directly
        ; - We can handle each decimal digit step-by-step without using loops

        ; --------------------------------------------------------------
        ; First digit (ten-thousands)
        LDX     #10000                      ; Load divisor 10000
        IDIV                                ; D/X -> X = quotient (digit), D = remainder
        PSHD                                ; Save remainder (rest) on stack
        TFR     X, D                        ; Move digit into D
        ADDD    #'0'                        ; Convert to ASCII ('0'..'9')
        STAB    1,Y                         ; Store ASCII character at position 1

        ; --------------------------------------------------------------
        ; Second digit (thousands)
        LDX     #1000
        PULD                                ; Restore previous remainder
        IDIV
        PSHD
        TFR     X, D
        ADDD    #'0'
        STAB    2,Y                         ; Store at position 2

        ; --------------------------------------------------------------
        ; Third digit (hundreds)
        LDX     #100
        PULD
        IDIV
        PSHD
        TFR     X, D
        ADDD    #'0'
        STAB    3,Y                         ; Store at position 3

        ; --------------------------------------------------------------
        ; Fourth digit (tens)
        LDX     #10
        PULD
        IDIV
        PSHD
        TFR     X, D
        ADDD    #'0'
        STAB    4,Y                         ; Store at position 4

        ; --------------------------------------------------------------
        ; Fifth digit (units)
        PULD                                ; Get last remainder (units place)
        ADDD    #'0'
        STAB    5,Y                         ; Store at position 5

        ; --------------------------------------------------------------
        ; Step 3: Restore saved registers
        PULD
        PULX
        PULY
        RTS                                 ; Return from subroutine
