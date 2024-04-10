
; Keypad decoder for keypad on PORT D
; R0, R1, R2, R3, C0, C1, C2, C3

.nolist
.include "M328Pdef.inc"
.list

.def	TEMP = R16
.def	SHIFT_COUNT = r17
.def	Key_In = R18
.def 	BUTTON = R19
.def 	ZERO = R2

.ORG	$0000
		rjmp	RESET
.ORG	PCI2addr
		rjmp	FindRow

.ORG	INT_VECTORS_SIZE
RESET:
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP

		clr 	R2

		rcall	RowInit
		ldi 	TEMP, (1<<PCIE2)
		sts 	PCICR, TEMP

		sei

MAIN:
		nop
		nop
		nop
		rjmp	MAIN


RowInit:
		ldi 	TEMP, $0F
		out 	DDRD, TEMP
		ldi 	TEMP, $F0
		out 	PORTD, TEMP
; Set PIND 7..4 to simulate input highs
		ldi 	TEMP, $F0
		sts 	PCMSK2, TEMP
		sbi 	PCIFR, PCIF2
		ret

ColInit:
		ldi 	TEMP, $F0
		out 	DDRD, TEMP
		ldi 	TEMP, $0F
		out 	PORTD, TEmP
; Set PIND 3..0 to simulate input highs
		ldi 	TEMP, $0F
		sts 	PCMSK2, TEMP
		sbi 	PCIFR, PCIF2
		ret

FindRow:
		clr 	SHIFT_COUNT
		in  	Key_In, PIND
		andi	Key_In, $F0
		cpi 	Key_In, $F0
		brne	Pressed
		reti
Pressed:
		mov 	TEMP, Key_In
NextRow:
		inc 	SHIFT_COUNT
		lsl 	Key_In
		brcs	NextRow
		dec 	SHIFT_COUNT
		lsl 	SHIFT_COUNT
		lsl 	SHIFT_COUNT
		mov 	BUTTON, SHIFT_COUNT
FindCol:
		rcall	ColInit

		clr 	SHIFT_COUNT
		in  	Key_In, PIND
		andi	Key_In, $0F
NextCol:
		inc 	SHIFT_COUNT
		lsr 	Key_In
		brcs	NextCol
		dec 	SHIFT_COUNT
		ldi 	TEMP, 3
		sub 	TEMP, SHIFT_COUNT
		add 	BUTTON, TEMP
		ldi 	ZH, high(KeyVals<<1)
		ldi 	ZL, low(KeyVals<<1)
		add 	ZL, BUTTON
		adc 	ZH, ZERO
		lpm 	BUTTON, Z
		rcall	RowInit
		reti
ProgramEnd:

.org ProgramEnd + $20 - (ProgramEnd % 16)
KeyVals:
.db 	1, 2, 3, 10, 4, 5, 6, 11, 7, 8, 9, 12, 15, 0, 14, 13



		




