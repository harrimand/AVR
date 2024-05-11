; Timer 1 Servo Control on OC1A pin

.nolist
.include "m328pdef.inc"
.list

.equ	PWMperiod = 20000
.equ	PWMmax = 2000
.equ	PWMmid = 1500
.equ	PWMmin = 1000
.def	TEMP = R16
.def	TEMPL = R16
.def	TEMPH = R17
.def	posH = R15
.def	posL = R14
.def	maxH = R13
.def	maxL = R12
.def	midH = R11
.def	midL = R10
.def	minH = R9
.def	minL = R8

.ORG	$0000
		rjmp	RESET
.ORG	INT0addr
		rjmp	SERVOleft
.ORG	INT1addr
		rjmp	SERVOright
.ORG	INT_VECTORS_SIZE
RESET:
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP

		sbi 	DDRB, PB1; OC1A Pin Ouput
		cbi 	DDRD, PD3; INT1 input
		cbi 	DDRD, PD2; INT0 input
		sbi 	PORTD, PD3; Input Pull-Up Resistor
		sbi 	PORTD, PD2; Input Pull-Up Resistor
	
		ldi 	TEMP, (1<<ISC11)|(0<<ISC10)|(1<<ISC01)|(0<<ISC00)
		sts 	EICRA, TEMP ;Sense Falling Edge

		ldi 	TEMP, (1<<INT1)|(1<<INT0)
		out 	EIMSK, TEMP ; External Interrupts Enabled
		
		ldi 	TEMPH, high(PWMmax)
		ldi 	TEMPL, low(PWMmax)
		movw	maxH:maxL, TEMPH:TEMPL

		ldi 	TEMPH, high(PWMmid)
		ldi 	TEMPL, low(PWMmid)
		movw	midH:midL, TEMPH:TEMPL

		ldi 	TEMPH, high(PWMmin)
		ldi 	TEMPL, low(PWMmin)
		movw	minH:minL, TEMPH:TEMPL

		movw	posH:posL, midH:midL

		ldi 	TEMPH, high(PWMperiod)
		ldi 	TEMPL, low(PWMperiod)
		sts 	ICR1H, TEMPH ; Store High Byte First
		sts 	ICR1L, TEMPL

		sts 	OCR1AH, midH
		sts 	OCR1AL, midL

		ldi 	TEMP, (1<<COM1A1)|(0<<COM1A0)|(1<<WGM11)|(0<<WGM10)
		sts 	TCCR1A, TEMP

		ldi 	TEMP, (1<<WGM13)|(1<<WGM12)|(0<<CS12)|(0<<CS11)|(1<<CS10)
		sts 	TCCR1B, TEMP

		sei

MAIN:
		nop
		nop
		nop
		rjmp	MAIN

SERVOleft:
		sts 	OCR1AH, minH
		sts 	OCR1AL, minL
		reti

SERVoright:
		sts 	OCR1AH, maxH
		sts 	OCR1AL, maxL
		reti











