;State Machine  05-28-2016 

#define SIM 1	;Comment out and reassemble before programming microcontroller
;
;	STATE/SEQUENCE MODE SELECTION (PB7..PB6 inputs select Mode)
;
;PB7..6 = 0 0	Auto Select, Auto Triggered  Will go to next state in sequence
;PB7..6 = 0 1	Auto Select. PB5 Triggers    Will go to next state in sequence
;PB7..6 = 1 0	Manual State Select.  PB2..0 selects state PB5,2..0 triggers
;PB7..6 = 1 1	Manual Sequence.  PB2..0 selects sequence. PB5,2..0 triggers
;
;	Using R16 everywhere
;	Using X, Y, Z for addressing (Y only used in RESET)
;	Using Timer 0 for time delay
;	Using PB7, PB6 for Mode selection inputs
;	Using PB5 to trigger next sequence in mode 01
;	Using PB5 to trigger manual State/Sequence event without changing PB2..0
;				 PB2..0 changes will also trigger manual State/Sequence event
;	Using PB2, PB1, PB0 for State/Sequence selection inputs
;	Using PD6, PD5, PD4 for LED outputs
;	Using R17 for simulation mode
;
;
.nolist
.include "M328Pdef.inc"
.list

.MACRO STATEsequence
;Function Labels in desired sequence
;Can be more or less labels than listed in the ORDEREDstates table.
;Does not need to include all labels and can be duplicates.

.dw		STATE3, STATE5, STATE0, STATE2, STATE7, STATE1, STATE4, STATE6

.ENDMACRO

.MACRO ORDEREDstates
;Function Labels in ordered sequence 0..n
;Must include all labels selected by numbers 0..n (n = number of states - 1)

.dw		STATE0, STATE1, STATE2, STATE3, STATE4, STATE5, STATE6, STATE7

.ENDMACRO


.EQU	STATEtableAddress = SRAM_START + $A0	;Set desired RAM table address
.EQU	INITIALsequence = 3	;First state to run in sequence. 0..(NumStates - 1)

.EQU	SEQUENCEsize = ORDEREDtableStart - STATEtable	;Num States in sequence
.EQU	NUMstates = STATEtableEnd - ORDEREDtableStart	;Number of states total

.def	TEMP = R16
.def	TEMP2 = R17

.ORG	$0000
		rjmp	RESET
.ORG	PCI0addr
		rjmp	SEQUENCEselect
.ORG	INT_VECTORS_SIZE

RESET:
		ldi		TEMP, high(RAMEND)
		out		SPH, TEMP
		ldi		TEMP, low(RAMEND)
		out		SPL, TEMP

;Copy State Address Table
		ldi		ZH, high(STATEtable << 1)
		ldi		ZL, low(STATEtable << 1)
		ldi		XH, high(STATEtableAddress)
		ldi		XL, low(STATEtableAddress)
		ldi		YH, high(STATEtableEnd << 1)
		ldi		YL, low(STATEtableEnd << 1)
		ldi		TEMP, INITIALsequence
		st		X+, TEMP
COPYtable:
		lpm		TEMP, Z+
		st		X+, TEMP
		cp		ZL, YL
		cpc		ZH, YH
		brne	COPYtable
		
		ldi		TEMP, (1<<PB7)|(1<<PB6)|(1<<PB5)|(1<<PB2)|(1<<PB1)|(1<<PB0)
		out		PORTB, TEMP

		ldi		TEMP, (1<<PD6)|(1<<PD5)|(1<<PD4)	;LED Otuput Pins
		out		DDRD, TEMP

		ldi		TEMP, (1<<PCINT5)|(1<<PCINT2)|(1<<PCINT1)|(1<<PCINT0)
		sts		PCMSK0, TEMP

		ldi		TEMP, (1<<PCIE0)
		sts		PCICR, TEMP

		sei								

;PB7..6 = 0 0	Auto Select, Auto Triggered  Will go to next state in sequence
;PB7..6 = 0 1	Auto Select. PB5 Triggers    Will go to next state in sequence
;PB7..6 = 1 0	Manual State Select.  PB2..0 selects state PB5,2..0 triggers
;PB7..6 = 1 1	Manual Sequence.  PB2..0 selects sequence. PB5,2..0 triggers

;---------------------------------------------------------------
MAIN:
		nop
		sbic	PINB, PB7
		rjmp	MAIN
		sbis	PINB, PB6
		rcall	SEQUENCEselect
		nop
		rjmp	MAIN

;---------------------------------------------------------------
SEQUENCEselect:
		sbis	PINB, PB7	;Manual Sequence/State select if PB7 set
		rjmp	AUTOsequence	;Else Run next step in sequence
		sbis	PINB, PB6		;Else PB2..0 selects sequence
		rjmp	SELECTstate		;Else PB2..0 value sets state.

;Mode 11  Select Sequence        Sequence counter updated.
		ldi		XH, high(STATEtableAddress + 1)
		ldi		XL, low(STATEtableAddress + 1)
		in		TEMP, PINB
		andi	TEMP, $07
;Validate Input
		cpi		TEMP, SEQUENCEsize
		brcs	VALIDsequence
		reti	;Invalid Input.  Return
VALIDsequence:
		rjmp	STATEselected		

;Mode 10	;Running selected state without updating sequence counter.
SELECTstate:
		ldi		XH, high(STATEtableAddress + (SEQUENCEsize << 1) + 1)
		ldi		XL, low(STATEtableAddress + (SEQUENCEsize << 1) + 1)
		in		TEMP, PINB
		andi	TEMP, $07
;Validate Input
		cpi		TEMP, NUMstates
		brcs	VALIDstate
		reti	;Invalid Input.  Return
VALIDstate:
		lsl		TEMP
		add		XL, TEMP
		ld		ZL, X+
		ld		ZH, X
		icall
		nop
		reti		

;Mode 00 or 01  Run sequence and update sequence counter.
AUTOsequence:
		ldi		XH, high(STATEtableAddress)
		ldi		XL, low(STATEtableAddress)
		ld		TEMP, X+

STATEselected:
		lsl		TEMP
		add		XL, TEMP
		ld		ZL, X+
		ld		ZH, X
		icall

;Update Sequence Counter
		ldi		XH, high(STATEtableAddress)
		ldi		XL, low(STATEtableAddress)
		ld		TEMP, X
		inc		TEMP
		cpi		TEMP, SEQUENCEsize
		brne	NoResetSequenceCount
		clr		TEMP
NoResetSequenceCount:
		st		X+, TEMP
		nop
		reti

;---------------------------------------------------------------
#ifdef	SIM  ;Time Delay to run during simulation
DELAY:	;SIMULATION MODE (Short Time Delay and Fast Counter for Simulation)
		sbi		TIFR0, TOV0
		ldi		TEMP, (0<<CS02)|(0<<CS01)|(1<<CS00);For Simulation
		out		TCCR0B, TEMP
		ldi		TEMP, $F0	;For Testing
		out		TCNT0, TEMP
		ldi		TEMP, $01	;For Testing

WAIT:
		sbis	TIFR0, TOV0
		rjmp	WAIT
		sbi		TIFR0, TOV0
		ldi		TEMP2, $F0	;For Testing
		out		TCNT0, TEMP	;For Testing
		dec		TEMP
		brne	WAIT
		clr		TEMP
		out		TCCR0B, TEMP
		ret
#endif

;---------------------------------------------------------------

#ifndef	SIM		;Time Delay Approximate 1 Second with CPUclk = 1 MHz
DELAY:
		sbi		TIFR0, TOV0
		ldi		TEMP, (1<<CS02)|(0<<CS01)|(1<<CS00)
		out		TCCR0B, TEMP
;		clr		TEMP
		ldi		TEMP, $30	;Adjust to calibrate Time Delay
		out		TCNT0, TEMP
		ldi		TEMP, $04

WAIT:
		sbis	TIFR0, TOV0
		rjmp	WAIT
		sbi		TIFR0, TOV0
		dec		TEMP
		brne	WAIT
		clr		TEMP
		out		TCCR0B, TEMP
		ret
#endif

;---------------------------------------------------------------

STATE0:
		nop
		in		TEMP, PIND
		andi	TEMP, $8F
		ori		TEMP, $00
		out		PORTD, TEMP
		rcall	DELAY
		nop
		ret
STATE1:
		nop
		in		TEMP, PIND
		andi	TEMP, $8F
		ori		TEMP, $10
		out		PORTD, TEMP
		rcall	DELAY
		nop
		ret
STATE2:
		nop
		in		TEMP, PIND
		andi	TEMP, $8F
		ori		TEMP, $20
		out		PORTD, TEMP
		rcall	DELAY
		nop
		ret
STATE3:
		nop
		in		TEMP, PIND
		andi	TEMP, $8F
		ori		TEMP, $30
		out		PORTD, TEMP
		nop
		ret
STATE4:
		nop
		in		TEMP, PIND
		andi	TEMP, $8F
		ori		TEMP, $40
		out		PORTD, TEMP
		rcall	DELAY
		nop
		ret
STATE5:
		nop
		in		TEMP, PIND
		andi	TEMP, $8F
		ori		TEMP, $50
		out		PORTD, TEMP
		nop
		ret
STATE6:
		nop
		in		TEMP, PIND
		andi	TEMP, $8F
		ori		TEMP, $60
		out		PORTD, TEMP
		rcall	DELAY
		nop
		ret
STATE7:
		nop
		in		TEMP, PIND
		andi	TEMP, $8F
		ori		TEMP, $70
		out		PORTD, TEMP
		rcall	DELAY
		nop
		ret

;---------------------------------------------------------------
STATEtable:
STATEsequence	;Macro defined at the beginning of program.
ORDEREDtableStart:
ORDEREDstates	;Macro defined at the beginning of program.
STATEtableEnd:
