; Author:  Darrell Harriman
; Sequence controller
; In Manual Select Mode (PB7 = 0) Pin Change Interrupt on PB2..0 select 
;    function to run.  When PB7 = 1, the next function in the sequence 
;    is run.  The function AUTOstate sequence position is stored at the first
;    address of STATEtable.



.nolist
.include "M328Pdef.inc"
.list

.def	TEMP = R16

.MACRO	STATEsequence
.dw		STATE3, STATE1, STATE0, STATE2, STATE7, STATE5, STATE4, STATE6 
.ENDMACRO

.equ	STATE = 0	;Sequence used for AUTOstate
.equ	STATEtable = SRAM_START + $A0

.ORG	$0000
		rjmp	RESET
.ORG	PCI0addr
		rjmp	STATEselect

RESET:
		ldi		TEMP, high(RAMEND)
		out		sph, TEMP
		ldi		TEMP, low(RAMEND)
		out		spl, TEMP

		ldi		TEMP, $87
		out		PORTB, TEMP	;Pull-Ups for state select input

		ldi		TEMP, (1<<PCINT2)|(1<<PCINT1)|(1<<PCINT0)
		sts		PCMSK0, TEMP

		ldi		TEMP, (1<<PCIE0)
		sts		PCICR, TEMP


		ldi		ZH, high(STATEseq << 1)
		ldi		ZL, low(STATEseq << 1)
		ldi		YH, high(STATEseqEND << 1)
		ldi		YL, low(STATEseqEND << 1)
		ldi		XH, high(STATEtable)
		ldi		XL, low(STATEtable)
		ldi		TEMP, STATE
		st		X+, TEMP
COPYstates:
		lpm		TEMP, Z+
		st		X+, TEMP
		cp		ZL, YL
		cpc		ZH, YH
		brne	COPYstates

		sei
MAIN:
		nop
		nop
		rjmp	MAIN



STATEselect:
		sbic	PINB, 7
		rjmp	AUTOstate
		ldi 	XH, high(STATEtable + 1)
		ldi 	XL, low(STATEtable + 1)
		in  	TEMP, PINB
		andi	TEMP, $07
		rjmp	STATEselected
AUTOstate:
		ldi		XH, high(STATEtable)
		ldi		XL, low(STATEtable)
		ld		TEMP, X
		inc		TEMP
		andi	TEMP, $07
		st		X+, TEMP
		dec		TEMP
STATEselected:
		lsl		TEMP
		add		XL, TEMP
		ld		ZL, X+
		ld		ZH, X+
		icall
		nop
		reti
;--------------------------------------------
STATE0:
		nop
		nop
		ret

STATE1:
		nop
		nop
		ret

STATE2:
		nop
		nop
		ret

STATE3:
		nop
		nop
		ret

STATE4:
		nop
		nop
		ret

STATE5:
		nop
		nop
		ret

STATE6:
		nop
		nop
		ret

STATE7:
		nop
		nop
		ret

	

STATEseq:
STATEsequence
STATEseqEND:
