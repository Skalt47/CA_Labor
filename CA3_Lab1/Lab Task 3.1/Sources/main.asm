;   Lab Task 3.1
;   Labor 1 - Test program for LCD driver
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   	   J.Friedrich, W. Zimmermann
;   Last Modified: R. Keller, August 2022
; Modified by: Erg�n Bickici & Tim Jauch

; --------------------------------------------------------------
; Exported symbols
        XDEF    Entry, main

; Imported symbols
        XREF    __SEG_END_SSTACK           ; End of stack
        XREF    initLCD, writeLine, delay_10ms

; Include device-specific register definitions
        INCLUDE 'mc9s12dp256.inc'

; --------------------------------------------------------------
; RAM: Variable data section
.data:  SECTION

; --------------------------------------------------------------
; ROM: Constant data section
.const: SECTION
MSG1:   dc.b " Mach mal eine",0
MSG2:   dc.b " kleine Pause", 0

msgA:   DC.B    "ABCDEFGHIJKLMnopqrstuvwxyz1234567890", 0  ; Message for LCD line 0
msgB:   DC.B    "is this OK?", 0                            ; Message for LCD line 1
msgC:   DC.B    "Keep texts short!", 0                      ; Message for LCD line 0
msgD:   DC.B    "Oh yeah!", 0                               ; Message for LCD line 1


; --------------------------------------------------------------
; ROM: Code section
.init:  SECTION

; --------------------------------------------------------------
; Main program
main:
Entry:
        LDS     #__SEG_END_SSTACK             ; Initialize stack pointer
        CLI                                   ; Enable interrupts (required for debugger)

        ; Initial delay after power-up
        JSR     delay_10ms
        JSR     delay_10ms

        ; Initialize LCD
        JSR     initLCD

        ; Display first message pair
        LDX     #MSG1
        LDAB    #0                            ; Write to LCD line 0
        JSR     writeLine

        LDX     #MSG2
        LDAB    #1                            ; Write to LCD line 1
        JSR     writeLine

        ; Wait before changing text
        JSR     delay

        ; Display second message pair
        LDX     #msgA
        LDAB    #0
        JSR     writeLine

        LDX     #msgB
        LDAB    #1
        JSR     writeLine

        ; Wait before changing text
        JSR     delay

        ; Display third message pair
        LDX     #msgC
        LDAB    #0
        JSR     writeLine

        LDX     #msgD
        LDAB    #1
        JSR     writeLine

        ; Final wait
        JSR     delay

; --------------------------------------------------------------
; Delay subroutine (approximately 4 second delay)
delay:
        PSHA                                  ; Save A register
        LDAA    #400                          ; Load counter for 400 x 10ms = ~4s
        JSR     loopDelay
        PULA                                  ; Restore A register
        RTS

; --------------------------------------------------------------
; Loop subroutine used by delay
loopDelay:
        DECA                                  ; Decrement A
        JSR     delay_10ms                    ; Wait 10 ms
        CMPA    #0
        BNE     loopDelay                     ; Repeat until A == 0
        RTS

; --------------------------------------------------------------
; Infinite loop to prevent program from exiting
back:
        BRA     back