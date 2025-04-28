;
;   Labor 1 - Test program for LCD driver
;
;   Computerarchitektur
;   (C) 2019-2022 J. Friedrich, W. Zimmermann, R. Keller
;   Hochschule Esslingen
;
;   Author:   	   J.Friedrich, W. Zimmermann
;   Last Modified: R. Keller, August 2022

; Export symbols
        XDEF Entry, main

; Import symbols
        XREF __SEG_END_SSTACK                   ; End of stack
        XREF initLCD, writeLine, delay_10ms     ; LCD functions
        XREF decToASCII, hexToASCII             ; ASCII functions
        XREF initLED, setLED                    ; LED functions
        XREF delay_0_5sec                       ; Delay (busy wait) for 0.5 seconds

; Include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

; Defines

; RAM: Variable data section
.data:  SECTION
Vtext:   dc.b 17

; ROM: Constant data
.const: SECTION

; ROM: Code section
.init:  SECTION

main:
Entry:
        LDS  #__SEG_END_SSTACK          ; Initialize stack pointer
        CLI                             ; Enable interrupts, needed for debugger
        
        JSR initLED 
        JSR initLCD                     

        LDD #0
loop:   
        LDX #Vtext                      ; Write D as decimal number onto line 0
        JSR decToASCII
        PSHD
        LDAB #0                         ; Write to line 0
        JSR  writeLine
        PULD

        LDX #Vtext                      ; Write D as hex number onto line 1
        JSR hexToASCII
        PSHD
        LDAB #1                         ; Write to line 1
        JSR  writeLine
        PULD

        JSR setLED                      ; Set LEDs to lower value in D (B)

        JSR delay_0_5sec

  IFDEF  SIMULATOR
        BRSET PTH, #$01, inc16
        BRSET PTH, #$02, inc10
        BRSET PTH, #$04, dec16
        BRSET PTH, #$08, dec10
  ELSE
        BRCLR PTH, #$01, inc16
        BRCLR PTH, #$02, inc10
        BRCLR PTH, #$04, dec16
        BRCLR PTH, #$08, dec10
        BRA inc
  ENDIF

inc16:
        ADDD #16
        BRA loop
inc10:
        ADDD #10
        BRA loop
dec16:
        SUBD #16
        BRA loop
dec10:
        SUBD #10
        BRA loop
inc:
        ADDD #1
        BRA loop


back:   BRA back
