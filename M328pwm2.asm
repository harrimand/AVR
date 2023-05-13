/*  ATmega 328P PWM Demo
	Darrell Harriman

*/

.nolist
.include "m328pdef.inc"
.list

.def	TEMP = R16
.def	T1Count = R17
.def	ServoPosH = R25
.def	ServoPosL = R24
.def	ServoMaxH = R15
.def	ServoMaxL = R14
.def	ServoMidH = R13
.def	ServoMidL = R12
.def	ServoMinH = R11
.def	ServoMinL = R10
.def	ServoStep = R9
.def 	Zero = R8

.equ	ServoT = 20000
.equ	ServoMID = 1500 ; Microseconds
.equ	ServoLEFT = 1000
.equ	ServoRIGHT = 2000
.equ	StepSize = 20

.ORG	$0000
		rjmp	RESET
.ORG	OVF1addr
		rjmp	servoSweep2
.ORG	INT_VECTORS_SIZE
RESET:
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP
;---------------------------------------------------
;Timer 1 OC1B
		sbi 	DDRB, PB2 ; OC1B Pin Output
		
		ldi 	TEMP, high(ServoRIGHT)
		mov 	ServoMaxH, TEMP
		ldi 	TEMP, low(ServoRIGHT)
		mov 	ServoMaxL, TEMP

		ldi 	TEMP, high(ServoMID)
		mov 	ServoMidH, TEMP
		ldi 	TEMP, low(ServoMID)
		mov 	ServoMidL, TEMP

		ldi 	TEMP, high(ServoLEFT)
		mov 	ServoMinH, TEMP
		ldi 	TEMP, low(ServoLEFT)
		mov 	ServoMinL, TEMP

		ldi 	TEMP, high(ServoT)
		sts 	ICR1H, TEMP
		ldi 	TEMP, low(ServoT)
		sts 	ICR1L, TEMP

		ldi 	ServoPosH, high(ServoMID)
		sts 	OCR1BH, ServoPosH

		ldi 	ServoPosL, low(ServoMID)
		sts 	OCR1BL, ServoPosL

		ldi 	TEMP, (1<<COM1B1)|(0<<COM1B0)|(1<<WGM11)|(0<<WGM10)
		sts 	TCCR1A, TEMP

		ldi 	TEMP, (1<<TOIE1)
		sts 	TIMSK1, TEMP
		
		ldi 	TEMP, (1<<WGM13)|(1<<WGM12)|(0<<CS12)|(0<<CS11)|(1<<CS10)
		sts 	TCCR1B, TEMP ; MCU clk / 1
;---------------------------------------------------		
		ldi 	TEMP, StepSize
		mov		ServoStep, TEMP
		clr 	TEMP
		clr 	T1Count
		
		sei

MAIN:
		nop
		nop
		rjmp	MAIN


servoSweep:
		push	TEMP
		inc 	T1Count
		cpi 	T1Count, 50
		brne	noSweep
		clr 	T1Count
		sbis	GPIOR0, 7
		rjmp	goLeft
		ldi 	TEMP, high(ServoRIGHT)
		sts 	OCR1BH, TEMP
		ldi 	TEMP, low(ServoRIGHT)
		sts 	OCR1BL, TEMP
		cbi 	GPIOR0, 7
		pop 	TEMP
		reti
goLeft:
		ldi 	TEMP, high(ServoLEFT)
		sts 	OCR1BH, TEMP
		ldi 	TEMP, low(ServoLEFT)
		sts 	OCR1BL, TEMP
		sbi 	GPIOR0, 7
		pop 	TEMP
		reti
noSweep:
		pop 	TEMP
		reti

servoSweep2:
		push	TEMP
		sbis	GPIOR0, 7
		rjmp	SweepLeft
		adiw	ServoPosH:ServoPosL, StepSize
		cp  	ServoPosL, ServoMaxL
		cpc 	ServoPosH, ServoMaxH
		brmi	notMax
		mov 	ServoPosH, ServoMaxH
		mov 	ServoPosL, ServoMaxL
		sbi 	GPIOR0, 7
notMax:
		sts 	OCR1BH, ServoPosH
		sts 	OCR1BL, ServoPosL
		pop 	TEMP
		reti
SweepLeft:
		sbiw	ServoPosH:ServoPosL, StepSize
		cp  	ServoPosL, ServoMinL
		cpc 	ServoPosH, ServoMinH
		brpl	notMin
		mov 	ServoPosH, ServoMaxH
		mov 	ServoPosL, ServoMaxL
		cbi 	GPIOR0, 7
notMin:
		sts 	OCR1BH, ServoPosH
		sts 	OCR1BL, ServoPosL
		pop 	TEMP
		reti




