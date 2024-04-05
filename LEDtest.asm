; Test Program to blink an LED

.nolist
.include "m328pdef.inc"
.list

.def	TEMP = R16

.ORG	$0000
		rjmp	RESET
.ORG	OVF0addr
		rjmp	BlinkLED
.ORG	INT_VECTORS_SIZE
RESET:
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RaMEND)
		out 	SPL, TEMP

		sbi 	DDRB, PB0 ; PORTB 0 output
		sbi		DDRB, PB1
		sbi 	PINB, PB1

		ldi 	TEMP, (1<<TOIE0)
		sts 	TIMSK0, TEMP; Timer 0 Overflow Interrupt

		;Clock Prescaler = Mcu/Clk / 1024
		ldi 	TEMP, (1<<CS02)|(0<<CS01)|(1<<CS00)
		out 	TCCR0B, TEMP

		sei

MAIN:
		nop
		nop
		nop
		rjmp	MAIN

BlinkLED:
		ldi 	TEMP, $0C
		out 	TCNT0, TEMP
		sbi 	PINB, PB0 ; Toggle LED
		sbi 	PINB, PB1
		reti
