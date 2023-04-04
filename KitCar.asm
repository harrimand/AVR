;Darrell Harriman
;Testing AVR download

.nolist
.include "M328Pdef.inc"
.list

.def	TEMP = R16
.def	TEMP2 = R17
.def	COUNT = R18
.def	kitSource = R25
.def	kit = R24
;.def	kitL = R23

.ORG	$0000
		rjmp	RESET
.ORG	OVF0addr
		rjmp	kitFun
.ORG	INT_VECTORS_SIZE

RESET:
		ldi 	TEMP, high(RAMEND)  ; Stack pointer at RAMEND
		out		SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out		SPL, TEMP

		ser 	TEMP 		;PORTB all pins output
		out 	DDRB, TEMP

		clr 	COUNT

		ser		TEMP
		mov		kit, TEMP

		ldi 	TEMP, (1<<TOIE0)  ; Timer 0 Overflow Interrupt Enable
		sts  	TIMSK0, TEMP

		ldi 	TEMP, (1<<CS02)|(0<<CS01)|(1<<CS00)  ; MCUclk / 1024
		out 	TCCR0B, TEMP

		ldi 	TEMP, (1<<SE)  ; Sleep mode 0 (Idle) enabled.
		out 	SMCR, TEMP

		sei

MAIN:
		nop
		nop
		sleep   ; Sleep and wait for interrupt to wake up
		nop
		rjmp	MAIN

T0ovf:  ;Interrupt Service Routine
		ldi		TEMP, $80
		out		TCNT0, TEMP 
		inc 	COUNT
		out 	PORTB, COUNT
		reti


KitFun:
		push	TEMP
		ldi		TEMP, $C0
		out		TCNT0, TEMP
		tst		kit
		brne	noInit
		ser		kitSource
		in		TEMP, GPIOR0
		ldi		TEMP2, $01
		eor		TEMP, TEMP2
		out		GPIOR0, TEMP
		ser		kitSource
noInit:
		in		TEMP, GPIOR0
		sbrs	TEMP, 0
		rjmp	ShiftRight
		rol		kitSource
		rol		kit
		rjmp Return
ShiftRight:
		ror		kitSource
		ror		kit
Return:
		out		PORTB, kit
		pop		TEMP
		reti
