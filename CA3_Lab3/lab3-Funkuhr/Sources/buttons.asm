  IFNDEF _HCS12_SERIALMON
    IFNDEF SIMULATOR 
SIMULATOR: EQU 1
    ENDIF
  ENDIF

; Export symbols
        XDEF modeButton

; Import symbols
        XREF mode
        XREF delay_10ms

; Include derivative specific macros
        INCLUDE 'mc9s12dp256.inc'

; Defines

; RAM: Variable data section
.data:  SECTION

; ROM: Constant data
.const: SECTION

.intVect: SECTION

; ROM: Code section
.init:  SECTION

;**************************************************************
; Public interface function: modeButton ... button to switch
; the clock mode
; Parameter: -
; Return: -
; Registers: Unchanged (when function returns)
modeButton:
  IFDEF SIMULATOR
    BRCLR PTH, #$08, sim
    JMP modeChange
sim:
    RTS
  ELSE
    BRCLR PTH, #$08, modeChange
    RTS
  ENDIF
    
modeChange:
    PSHD
    LDAA mode                                   ; If button is pressed and mode was 1 set mode to 0
    CMPA #0
    BEQ setM
    LDAA #0
    STAA mode
    PULD
    BRA back
    
  
setM:                                           ; If button is pressed and mode was 0 set mode to 1
    LDAA #1
    STAA mode  
    PULD
    BRA back
back:
    JSR delay_0_2sec                            ; Wait for 0,2s to stop the function to be called more than once when button is pressed
    RTS    

delay_0_2sec:
    PSHD
    LDAB #21
wait:
    JSR delay_10ms
    DECB
    CMPB #0
    BNE wait
    PULD
    RTS
    
    
    