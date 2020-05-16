
; Atmega 164 Program to test deBounce Macro

.nolist
.include "m164pdef.inc"
.include "M164deBounceMacro.asm"
.list

.def 	TEMP = R16
.def	row = R19
.def	column = R18
.def 	button = R17

.ORG	$0000
		rjmp	RESET
.ORG	PCI2addr
		rjmp	PC2isr
.ORG	INT_VECTORS_SIZE
RESET:
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP

		ldi 	TEMP, (1<<JTD)
		out 	MCUCR, TEMP
		out 	MCUCR, TEMP

		ldi 	TEMP, 0b00001111
		sts 	PCMSK2, TEMP

		ldi 	TEMP, (1<<PCIE2)
		sts 	PCICR, TEMP

		clr 	TEMP
		out 	DDRC, TEMP  ; All pins input

		ldi 	TEMP, $0F
		out 	PORTC, TEMP ;Enable Pull-Up Resistors on Pins 3..0

		ldi 	TEMP, (1<<SE)
		out 	SMCR, TEMP

		sei

MAIN:
		nop
		sleep
		nop
		rjmp	MAIN

PC2isr:
		push	row
		push	column
		push	button
;rcall	TestMacro
deBounce PINC, $0F, 50
		in  	TEMP, PINC
		clr 	column
		clr 	row
nextCol:
		inc 	column
		lsr 	TEMP
		brcs	nextCol
		dec 	column
		ldi 	TEMP, $0F
		out 	DDRC, TEMP
		ldi 	TEMP, $F0
		out 	PORTC, TEMP
		nop
		nop
		in  	TEMP, PINC
nextRow:
		inc 	row
		lsl 	TEMP
		brcs	nextRow
		dec 	row
		ldi 	TEMP, $F0
		out 	DDRC, TEMP
		ldi 	TEMP, $0F
		out 	PORTC, TEMP
		ldi 	TEMP, 4
		mul 	row, TEMP
		mov 	TEMP, column
		add 	TEMP, R0
		sbi 	PCIFR, PCIF2
		pop 	button
		pop 	column
		pop 	row
		ldi 	ZH, high(ButtonTableStart<<1)
		ldi 	ZL, low(ButtonTableStart<<1)
		add 	ZL, TEMP
		lpm 	TEMP, Z
		reti

/*
TestMacro:
.def	TEMP2 = R16
.def	COUNT = R17
.def	pinMask = R18 
.def	input = R20

		push TEMP2
		push COUNT
		push pinMask
		push input


dbStart:
		in  	TEMP2, PINC
		andi	TEMP2, $0F
		ldi 	COUNT, 20
nextRead:
		in  	input, PINC
		andi	input, $0F
		cp  	TEMP2, input
		brne	dbStart
		dec 	COUNT
		brne	nextRead
		pop 	input
		pop 	pinMask
		pop 	COUNT
		pop 	TEMP2
		ret
*/

		
ButtonTableStart:
.db		$07, $08, $09, $0A

.db		$04, $05, $06, $0B

.db 	$01, $02, $03, $0C

.db 	$00, $0D, $0E, $0F
ButtonTableEnd:
