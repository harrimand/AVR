; Input Capture Register on Timer 1 Demo

.nolist
.include "m328pdef.inc"
.list

.def	TEMPH = R17
.def	TEMP = R16
.def 	InCapH = R7
.def	InCapL = R6
.def	PWMbH = R15
.def	PWMbL = R14

.ORG	$0000
		rjmp	RESET
.ORG	ICP1addr
		rjmp	captureISR
.ORG	INT_VECTORS_SIZE
RESET:
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP

		sbi 	DDRB, PB2 ; OC1B PWM output pin
		cbi 	DDRB, PB0 ; Input Capture Input
		sbi 	PORTB, PB0 ; Pullup Enabled

		ldi 	TEMP, high(20000)
		sts 	OCR1AH, TEMP
		ldi 	TEMP, low(20000)
		sts 	OCR1AL, TEMP	; PWM Top Register

		ldi 	TEMP, high(1500)
		mov 	PWMbH, TEMP
		sts 	OCR1BH, PWMbH	;PWM Servo Mid Position High Byte

		ldi 	TEMP, low(1500)
		mov 	PWMbL, TEMP
		sts 	OCR1BL, PWMbL	;PWM Servo Mid Position Low Byte

		ldi 	TEMP, (1<<ICIE1)
		sts 	TIMSK1, TEMP	;Input Capture Interrupt Enable

		ldi 	TEMP, (1<<COM1B1)|(0<<COM1B0)|(1<<WGM11)|(1<<WGM10)

		ldi 	TEMP, (1<<ICES1)|(1<<WGM13)|(1<<WGM12)|(0<<CS02)|(0<<CS01)|(1<<CS00)
		sts 	TCCR1B, TEMP

		sei

MAIN:
		nop
		nop
		rjmp	MAIN

captureISR:
		push	TEMP
		push	TEMPH
		lds 	TEMP, TCCR1B
		sbrc 	TEMP, ICES1
		rjmp	StartCapture\
;End Capture
		sbr 	TEMP, ICES1
		sts 	TCCR1B, TEMP\
		lds  	TEMP, ICR1L
		lds 	TEMPH, ICR1H
		sub 	InCapL, TEMP
		sbc 	InCapH, TEMPH
		pop 	TEMPH
		pop 	TEMP
		reti
StartCapture:
		sbr 	TEMP, ICES1
		sts 	TCCR1B, TEMP\
		lds  	InCapL, ICR1L
		lds 	InCapH, ICR1H
		pop 	TEMPH
		pop 	TEMP
		reti
