; Lab 1 - Preparation Task 1.2
; Delay function (~0.5 seconds) using nested loops
;
; Computerarchitektur
; (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
; Hochschule Esslingen
;
; Modified by: Ergün Bickici & Tim Jauch

; --------------------------------------------------------------
; Exported symbols
        XDEF    delay_0_5sec

; Include device-specific register definitions
        INCLUDE 'mc9s12dp256.inc'

; --------------------------------------------------------------
; Constant definitions
time:       EQU     1950

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
; Public interface function: delay_0_5sec
; Purpose: Create a software delay (~0.5 seconds)
; Parameter: -
; Returns: -
; Registers modified: X, Y
; Error checks: None
; Notes:
; - Uses two nested counter loops (X and Y).

delay_0_5sec:
        PSHX                                ; Save register X
        PSHY                                ; Save register Y
        LDX     #time                       ; Outer loop counter

waitO:
        LDY     #time                       ; Inner loop counter
waitI:
        DBNE    Y, waitI                    ; Decrement Y and loop if not zero
        DBNE    X, waitO                    ; Decrement X and loop if not zero
        PULY                                ; Restore Y
        PULX                                ; Restore X
        RTS                                 ; Return from subroutine
