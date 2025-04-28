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
        XDEF toLower

; Defines

; Defines

; RAM: Variable data section
.data: SECTION

; ROM: Constant data
.const: SECTION

; ROM: Code section
.init: SECTION

toLower:
        PSHD ;Registern sichern
        PSHX 
        PSHY
        TFR D,X
weiter: 
        LDAB 0,X 
        TSTB 
        BEQ ende      
        CMPB #'A'
        BLO next
        CMPB #'Z'
        BHI next
        ADDB #32
        STAB 0,X 
next:
        INX 
        BRA weiter  
ende:
        PULY
        PULX
        PULD
        RTS
                      