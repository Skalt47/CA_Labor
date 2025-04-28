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
        XREF decToASCII
        XREF hexToASCII
        XREF initLED
        XREF setLED
        XREF delay_0_5sec

; Include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

; Defines

; RAM: Variable data section
.data:  SECTION
i: DS.W 1
dec: DS.B 7
hex: DS.B 7
 

; ROM: Constant data
.const: SECTION


; ROM: Code section
.init:  SECTION

main:
Entry:

 LDS  #__SEG_END_SSTACK  ; Initialize stack pointer
 CLI                     ; Enable interrupts, needed for debugger

; Variabeln initsialisieren
        JSR  delay_10ms                 ; Delay 20ms during power up
        JSR  delay_10ms

        JSR  initLCD                    ; Initialize the LCD
        JSR  initLED

        MOVW #0, i

loop2:
        LDD i           ; Lade in D i  
        BRSET PTH, #$01, Button0Pressed                 
        BRSET PTH, #$02, Button1Pressed 
        BRSET PTH, #$04, Button2Pressed 
        BRSET PTH, #$08, Button3Pressed
        ADDD #1         ; Addiere auf D 1
        BRA END

Button0Pressed:
        ADDD #16
        BRA END
Button1Pressed:
        ADDD #10
        BRA END
Button2Pressed:
        SUBD #10
        BRA END
Button3Pressed:
        SUBD #1
        BRA END                        
        
END:    STD i           ; Speicher D in i
        JSR setLED      ; Zeige LEDs
        JSR showLCD     ; Zeig LEDS
        BRA loop2       ; zähl hoch

showLCD:
        PSHD            ; sichere Register
        PSHX
        PSHY 

        LDX  #dec       ; Übergebe Parameter
        LDD i           ; Übergebe Parameter
        JSR decToASCII  ; Umwandeln
        LDAB #0         ; Write to line 0
        JSR  writeLine  ; Schreiben

        LDX #hex        ; Übergebe Parameter
        LDD i           ; Lade in D i
        JSR hexToASCII  ; Umwandeln
        LDAB #1         ; Write to line 1
        JSR writeLine   ; Schreiben
        PULY
        PULX 
        PULD
        JSR delay_0_5sec
        RTS






        

delay:
        PSHD
        PSHX
        PSHY
        LDAA #50                       ; Warte 100 Einheiten
        JSR loop1 
        PULY
        PULX
        PULD
        RTS
loop1:
        DECA                            ; Decrement A
        JSR delay_10ms                  ; Wait 10 ms and decrement A, as long it is not equal 0
        CMPA #0                         
        BNE loop1
        RTS
