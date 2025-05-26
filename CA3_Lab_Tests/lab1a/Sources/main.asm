;   Labor 1 - Problem 2.2
;   Incrementing a value once per second and binary output to LEDs
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
        XDEF    Entry, main

; import symbols
        XREF    __SEG_END_SSTACK            ; End of stack

; include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

.data: SECTION
counter: DS.B 1

.const: SECTION
msg:  DC.B "Hello LCD!", 0

.init: SECTION
Entry:
main:
  LDX   #msg
  LDAB  #0
  JSR   writeLine


back:
  BRA back   