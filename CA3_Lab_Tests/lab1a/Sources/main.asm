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

; Defines
SPEED_X:    EQU     1000                    ; Outer loop counter value
SPEED_Y:    EQU     10000                   ; Inner loop counter value

; RAM: Variable data section
.data:  SECTION
counter_L:  DS.B    1                       ; Low byte of counter (8 bits)
counter_H:  DS.B    1                       ; High byte of counter (8 bits)

; ROM: Constant data
.const: SECTION

; ROM: Code section
.init:  SECTION

main:                                       ; Begin of the program
Entry:
        LDS     #__SEG_END_SSTACK           ; Initialize stack pointer
        CLI                                 ; Enable interrupts, needed for debugger
        
        LDAA    #$FF                        ; Load all bits to 1 in A
        STAA    DDRB                        ; Set PORTB pins as outputs

loop:
        LDAA    #$FF                        ; Load all bits to 1 in A
        STAA    PORTB                       ; Set PORTB outputs to high (LEDs ON)
        JSR     delay                       ; Call delay subroutine
  
        LDAA    #$00                        ; Load all bits to 0 in A
        STAA    PORTB                       ; Set PORTB outputs to low (LEDs OFF)
        JSR     delay                       ; Call delay subroutine
  
        BRA     loop                        ; Branch back to loop

delay:
        LDX     #SPEED_X                    ; Load outer loop counter
outer_loop:
        LDY     #SPEED_Y                    ; Load inner loop counter
inner_loop:
        DEY                                 ; Decrement Y
        BNE     inner_loop                  ; Branch if not zero
        
        DEX                                 ; Decrement X
        BNE     outer_loop                  ; Branch if not zero
        
        RTS                                 ; Return from subroutine
