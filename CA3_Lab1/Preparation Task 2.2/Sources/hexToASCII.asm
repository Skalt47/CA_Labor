;   Labor 1 - Problem 2.4
;   Convert a zero-terminated ASCIIZ string to lower characters
;   Subroutine toLower
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   R. Keller, HS-Esslingen
;            (based on code provided by J. Friedrich, W. Zimmermann)
;   Modified: -
;


; export symbols
        XDEF hexToASCII

; Defines

; Defines

; RAM: Variable data section
.data: SECTION

; ROM: Constant data
.const: SECTION

; ROM: Code section
.init: SECTION
H2A: DC.B "0123456789ABCDEF";   Define H2A ROM rable to read digit as index

hexToASCII:
    PSHY
    PSHX
    PSHD


    MOVB #'0', 0, X
    MOVB #'x', 1, X
    MOVB #0, 6, X

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
    LSRD

    ; Zusammenarbeit mit Philipp Walter und Alex Efremidis    
    ANDB #$0F
    TFR B, Y
    LDD H2A, Y   ; D = H2A + Y
    STAA 2,x     ; A = x + 2
    PULD
    ; Ende Zusammenarbeit






    PSHD
    
    LSRD
    LSRD
    LSRD
    LSRD
    LSRD
    LSRD
    LSRD
    LSRD

    ; Zusammenarbeit mit Philipp Walter und Alex Efremidis
    ANDB #$0F
    TFR B, Y
    LDD H2A, Y
    STAA 3,x
    PULD
    ; Ende Zusammenarbeit




    PSHD
    LSRD
    LSRD
    LSRD
    LSRD

    ; Zusammenarbeit mit Philipp Walter und Alex Efremidis    
    ANDB #$0F
    TFR B, Y
    LDD H2A, Y
    STAA 4,x
    PULD
    ; Ende Zusammenarbeit

    PSHD
    
    ANDB #$0F
    TFR B, Y
    LDD H2A, Y
    STAA 5,x








    PULD
    PULX
    PULY
    RTS
