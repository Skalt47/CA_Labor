; Lab 1 - Preparation Task 1.2
; 16-bit counter, incrementing by 2, output to LEDs with delay
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
        XREF    __SEG_END_SSTACK
        XREF    delay_0_5sec
        XREF    initLED
        XREF    setLED
        XREF    getLED
        XREF    toggleLED

; Include device-specific register definitions
        INCLUDE 'mc9s12dp256.inc'

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
; Main program
main:
Entry:
        LDS     #__SEG_END_SSTACK            ; Initialize stack pointer
        CLI                                  ; Enable interrupts

        ; Initialize LED hardware
        JSR     initLED

; --------------------------------------------------------------
; Main counting and display loop
resetCounter:
        LDD     #0                           ; Clear 16-bit counter (D register)
        MOVB    #0, PORTB                    ; Turn off all LEDs

mainLoop:
        CPD     #63                          ; Compare counter (D) with 63
        BLO     below63                      ; If lower, continue counting
        BHI     resetCounter                 ; If higher, reset counter

below63:
        ; Output current counter value to LEDs
        JSR     setLED

        ; Update counter: add 2 to lower byte (B)
        JSR     getLED
        ADDB    #2

        ; Wait before next update
        JSR     delay_0_5sec

        BRA     mainLoop                     ; Repeat main counting loop
