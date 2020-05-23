
; Read quadrature encoder on INT0 and INT1
; INT0 on PD2   INT1 on PD3
;
;
.nolist
.include "M164pdef.inc"
.include "M164deBounceMacro.asm"
.list

.def	TEMP = R16
.def	TEMPH = R17
.def	COUNTER = R18
.def 	COUNTER2 = R19

.ORG	$0000
		rjmp	RESET
.ORG	INT0addr
		rjmp	quadA
.ORG	INT1addr
		rjmp	quadB
.ORG	PCI0addr
		rjmp	quad2A
.ORG	PCI2addr
		rjmp	quad2B

RESET:
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP

		ldi 	TEMP, (1<<JTD)	;Disable JTAG on PORTC
		out 	MCUCR, TEMP
		out 	MCUCR, TEMP

		cbi 	DDRD, PD2	; Input Pins
		cbi 	DDRD, PD3
		cbi 	DDRA, PA2
		cbi 	DDRC, PC3

		sbi 	PORTD, PD2 ; Pullups Enabled
		sbi 	PORTD, PD3
		sbi 	PORTA, PA2
		sbi 	PORTC, PC3

		ldi		TEMP, (0<<ISC11)|(1<<ISC10)|(0<<ISC01)|(1<<ISC00)
		sts 	EICRA, TEMP

		ldi 	TEMP, (1<<INT1)|(1<<INT0)
		out 	EIMSK, TEMP

		ldi 	TEMP, (1<<PCINT2)
		sts 	PCMSK0, TEMP
		ldi 	TEMP, (1<<PCINT19)
		sts 	PCMSK2, TEMP

		ldi 	TEMP, (1<<PCIE2)|(1<<PCIE0)
		sts 	PCICR, TEMP

		clr 	COUNTER
		clr 	COUNTER2

		sei

MAIN:
		nop
		nop	
		nop
		rjmp	MAIN




quadA:
deBounce PIND, (1<<PD3)|(1<<PD2), 20
; Compare PD3 with PD2.
; If different then clockwise
; If same then counterclockwise
		push	TEMP
		push	TEMPH
		clr 	TEMPH
		in  	TEMP, PIND
		bst 	TEMP, PD2
		andi	TEMP, (1<<PD3)
		bld 	TEMPH, PD3
		eor 	TEMP, TEMPH
		brne	countUP
		dec 	COUNTER
		pop 	TEMPH
		pop 	TEMP
		reti
countUP:
	`	inc 	COUNTER
		pop 	TEMPH
		pop 	TEMP
		reti

quadB:
deBounce PIND, (1<<PD3)|(1<<PD2), 20
; Compare PD3 with PD2.
; If different then counterclockwise
; If same then clockwise
		push	TEMP
		push	TEMPH
		clr 	TEMPH
	`	in  	TEMP, PIND
		bst 	TEMP, PD2
		andi	TEMP, (1<<PD3)
		bld 	TEMPH, PD3
		eor 	TEMP, TEMPH
		brne	countDOWN
		inc 	COUNTER
		pop 	TEMPH
		pop 	TEMP
		reti
countDOWN:
	`	dec 	COUNTER
		pop 	TEMPH
		pop 	TEMP
		reti

quad2A:
deBounce PINA, (1<<PA2), 20
; Compare PD3 with PD2.
; If different then clockwise
; If same then counterclockwise
		push	TEMP
		push	TEMPH
		clr 	TEMPH
		in  	TEMP, PINA
		andi	TEMP, (1<<PA2)
		lsl 	TEMP
		in  	TEMPH, PINC
		andi	TEMPH, (1<<PC3)
		eor 	TEMP, TEMPH
		brne	countUP2
		dec 	COUNTER2
		pop 	TEMPH
		pop 	TEMP
		reti
countUP2:
	`	inc 	COUNTER2
		pop 	TEMPH
		pop 	TEMP
		reti

quad2B:
deBounce PINC, (1<<PC3), 20
; Compare PD3 with PD2.
; If different then counterclockwise
; If same then clockwise
		push	TEMP
		push	TEMPH
		clr 	TEMPH
		in  	TEMP, PINA
		andi	TEMP, (1<<PA2)
		lsl 	TEMP
		in  	TEMPH, PINC
		andi	TEMPH, (1<<PC3)
		eor 	TEMP, TEMPH
		brne	countDOWN2
		inc 	COUNTER2
		pop 	TEMPH
		pop 	TEMP
		reti
countDOWN2:
	`	dec 	COUNTER2
		pop 	TEMPH
		pop 	TEMP
		reti
