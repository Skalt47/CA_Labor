;   Labor 1 - Preparation Task 2.3
;   Convert a 16-bit value in register D to a zero-terminated ASCIIZ string representing the value in dec
;   Subroutine decToASCII
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   R. Keller, HS-Esslingen
;            (based on code provided by J. Friedrich, W. Zimmermann)
;   Modified: Ergün Bickici & Tim Jauch
;

; export symbols
        XDEF decToASCII

; Defines

; RAM: Variable data section
.data: SECTION


; ROM: Constant data
.const: SECTION

; ROM: Code section
.init: SECTION

; -----------------------------------------------------------------------------

; Public interface function: decToASCII  convert given decimal (time) in ASCII (called before time will be printed)
; Parameter: -
; Return: -
; Registers: Unchanged (when function returns)


decToASCII:
        PSHX                            ; Save X on stack
        PSHY                            ; Save Y on stack
        PSHD                            ; Save D on stack

        EXG X, Y                        ; Transfer X and Y, because X and D are used alot leaving Y as pointer to the char

        CPD #0                          ; Compare D with 0
        BGE positive                    ; If D >= 0, jump to positive
        MOVB #'-', Y                    ; If negative, write '-' to the string
        INY                             ; Increment Y

        COMA                            ; Complement D     
        COMB
        INCB
positive:

        LDX #10000

next:
        PSHX                            ; Save X on stack
        IDIV                            ; Divide (D) / (X) ? X, Remainder ? D
        EXG X, D                        ; Exchange X and D

        CPD #0                          ; Check if X is zero
        BEQ skip                        ; If X == 0, skip to the next digit
write:
        ADDD #'0'                       ; Convert to ASCII by adding '0'
        STAB 1, Y+
skip:
        PULD                            ; Restore X into D from stack
        
        PSHX                            ; Save X on stack
        
        LDX #10
        IDIV                            ; Divide (D) / 10 ? X, Remainder ? D
        
        PULD                            ; Restore X into D from stack

        CPX #1                          ; Check if X is 1
        BNE next                        ; If X != 1, go to next digit

        ADDD #'0'                       ; Convert to ASCII by adding '0'
        STAB 1, Y+                      ; Write last digit to the string

        MOVB #0, Y                      ; Terminate the string

        PULD                            ; Restore D from stack
        PULY                            ; Restore Y from stack
        PULX                            ; Restore X from stack

        RTS