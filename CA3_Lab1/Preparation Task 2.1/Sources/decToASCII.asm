;   Labor 1 - Vorbereitungsaufgabe 2.4
;   Convert a zero-terminated ASCIIZ string to lower characters
;   Main program
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   R. Keller, Jul 4, 2019
;            (based on code provided by J. Friedrich, W. Zimmermann)
;   Modified: -
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

decToASCII:
        PSHX                            ; Save X on stack
        PSHY                            ; Save Y on stack
        PSHD                            ; Save D on stack

        TFR X, Y                        ; Transfer X and Y, because X and D are used alot leaving Y to as pointer to the char

        CPD #0                          ; Compare D with 0
        BLT negative                    ; Check if negative
        MOVB #' ', Y                    ; If positive, write ' ' to the string
        BRA continue
negative:
        MOVB #'-', Y                    ; If negative, write '-' to the string
        
        COMA
        COMB
        ADDD #1
continue:
        INY                             ; Increment Y

        LDX #10000
        IDIV                            ; Divide signed
        EXG X, D                        ; Exchange X and D
        ADDD #'0'                       ; Convert to ASCII by adding '0'
        STAB 1, Y+
        EXG D, X                        ; Exchange D and X back so that D contains the remainder again

        LDX #1000
        IDIV                            ; Divide signed
        EXG X, D                        ; Exchange X and D
        ADDD #'0'                       ; Convert to ASCII by adding '0'
        STAB 1, Y+
        EXG D, X                        ; Exchange D and X back so that D contains the remainder again

        LDX #100
        IDIV                            ; Divide signed
        EXG X, D                        ; Exchange X and D
        ADDD #'0'                       ; Convert to ASCII by adding '0'
        STAB 1, Y+
        EXG D, X                        ; Exchange D and X back so that D contains the remainder again

        LDX #10
        IDIV                            ; Divide signed
        EXG X, D                        ; Exchange X and D
        ADDD #'0'                       ; Convert to ASCII by adding '0'
        STAB 1, Y+
        EXG D, X                        ; Exchange D and X back so that D contains the remainder again

        ADDD #'0'                       ; Convert to ASCII by adding '0'
        STAB 1, Y+

        MOVB #0, Y                      ; Terminate the string

        PULD                            ; Restore D from stack
        PULY                            ; Restore Y from stack
        PULX                            ; Restore X from stack

        RTS
