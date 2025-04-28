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
        XDEF hexToASCII

; Defines

; RAM: Variable data section
.data: SECTION

; ROM: Constant data
.const: SECTION
H2A:   DC.B "0123456789ABCDEF"

; ROM: Code section
.init: SECTION

hexToASCII:
        PSHX                            ; Save X on stack
        PSHY                            ; Save Y on stack
        PSHD                            ; Save D on stack

        LDY #H2A                        ; Load pointer to the hex to ASCII table into Y

        MOVB #'0', X                    ; Write '0' to the string
        INX
        MOVB #'x', X                    ; Write 'x' to the string
        INX

        PSHD                            ; Save 16 bits of D on stack
        LSRD                            ; Shift D to the right 4 times
        LSRD
        LSRD
        LSRD

        PSHD                            ; Save 12 bits of D on stack
        LSRD                            ; Shift D to the right 4 times
        LSRD
        LSRD
        LSRD

        PSHD                            ; Save 8 bits of D on stack
        LSRD                            ; Shift D to the right 4 times
        LSRD
        LSRD
        LSRD                            ; Now D contains the last 4 bits

        LDAA B, Y                       ; Load the character that represents the first 4 bits from the hex to ASCII lookup string
        STAA 1, X+                      ; Store the character in the string

        PULD                            ; Restore 8 bits of D from stack
        ANDB #$0F                       ; Mask out the last 4 bits
        LDAA B, Y                       ; Load the character that represents the first 4 bits from the hex to ASCII lookup string
        STAA 1, X+                      ; Store the character in the string

        PULD                            ; Restore 12 bits of D from stack
        ANDB #$0F                       ; Mask out the last 4 bits
        LDAA B, Y                       ; Load the character that represents the first 4 bits from the hex to ASCII lookup string
        STAA 1, X+                      ; Store the character in the string

        PULD                            ; Restore 16 bits of D from stack
        ANDB #$0F                       ; Mask out the last 4 bits
        LDAA B, Y                       ; Load the character that represents the first 4 bits from the hex to ASCII lookup string
        STAA 1, X+                      ; Store the character in the string

        MOVB #0, X                      ; Terminate the string

        PULD                            ; Restore D from stack
        PULY                            ; Restore Y from stack
        PULX                            ; Restore X from stack

        RTS
