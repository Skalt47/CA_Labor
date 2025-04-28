; Labor 1 - Preparation Task 1.1
; 16-bit counter, incrementing by 2, output on LEDs with 0.5 seconds delay
;
; Computerarchitektur
; (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
; Hochschule Esslingen
;
; Modified by: Ergün Bickici & Tim Jauch

; --------------------------------------------------------------
; Exported symbols
        XDEF    Entry, main

; Imported symbols
        XREF    __SEG_END_SSTACK           ; End of stack

; Include device-specific register definitions
        INCLUDE 'mc9s12dp256.inc'

; --------------------------------------------------------------
; Constant definitions
SPEED_X:    EQU     300                    ; Outer loop counter value
SPEED_Y:    EQU     10000                  ; Inner loop counter value

; --------------------------------------------------------------
; RAM: Variable data section
.data:  SECTION
counter_L:  DS.B    1                       ; Low byte of counter (8 bits)
counter_H:  DS.B    1                       ; High byte of counter (8 bits)

; --------------------------------------------------------------
; ROM: Constant data
.const: SECTION

; --------------------------------------------------------------
; ROM: Code section
.init:  SECTION

; --------------------------------------------------------------
; Main program
main:
Entry:
        LDS     #__SEG_END_SSTACK           ; Initialize stack pointer
        CLI                                 ; Enable interrupts (required for debugger)

        ; Configure PORTB for output (set DDRB to all 1s)
        LDAA    #$FF
        STAA    DDRB

        ; Initialize 16-bit counter to 0
        CLRA
        STAA    counter_L
        STAA    counter_H

; --------------------------------------------------------------
; Main counting loop
loop:
        ; Output lower 8 bits of counter to LEDs
        LDAA    counter_L
        STAA    PORTB

        ; Call delay subroutine (~0.5 seconds)
        JSR     delay_0_5sec

        ; Increment counter by 2
        LDAA    counter_L
        ADDA    #2
        STAA    counter_L

        ; Check if counter >= 64
        CMPA    #64
        BLO     loop                        ; If lower, continue counting

        ; If 64 or more, reset counter
        CLRA
        STAA    counter_L
        STAA    counter_H

        BRA     loop                        ; Repeat forever

; --------------------------------------------------------------
; Public interface function: delay_0_5sec
; Purpose: Simple delay loop (~0.5 seconds)
; Parameters: -
; Returns: -
; Registers modified: X, Y
; Error checks: None
; Notes:
; - Only uses local registers for counting
; - Constants SPEED_X and SPEED_Y define delay length
delay_0_5sec:
        LDX     #SPEED_X                    ; Load outer loop counter
outer_loop:
        LDY     #SPEED_Y                    ; Load inner loop counter
inner_loop:
        DEY                                 ; Decrement Y
        BNE     inner_loop                  ; Repeat inner loop
        DEX                                 ; Decrement X
        BNE     outer_loop                  ; Repeat outer loop
        RTS                                 ; Return from subroutine
