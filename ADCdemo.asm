
; ADC Analog to digital conversion

.nolist
.include "m328pdef.inc"
.list

.def	TEMP = R16
.def	ADCHigh = R19
.def 	ADCLow = R18
.def 	PWMH = R15
.def 	PWML = R14
.def 	OffH = R13  ; Offset High Byte
.def 	OffL = R12  ; Offset Low Byte

.ORG	$0000
		rjmp	RESET
.ORG 	OVF0addr
		rjmp	OVF0isr
.ORG 	ADCCaddr
		rjmp	ReadADC
.ORG	INT_VECTORS_SIZE
RESET:

		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP

		clr 	TEMP
		out 	DDRC, TEMP
		ldi 	TEMP, (1<<ADC1D)|(1<<ADC0D)
		sts 	DIDR0, TEMP
		
		lds  	TEMP, PRR
		ori 	TEMP, $82  ;Disable TWI and USART0
		sts 	PRR, TEMP

		ldi 	TEMP, high(1500)
		mov 	PWMH, TEMP
		ldi 	TEMP, low(1500)
		mov 	PWML, TEMP

		ldi 	TEMP, high(1000)
		mov 	OffH, TEMP
		ldi 	TEMP, low(1000)
		mov 	OffL, TEMP

		ldi 	TEMP, (1<<TOIE0)
		sts 	TIMSK0, TEMP

		clr 	TEMP
		sts 	ADMUX, TEMP

		ldi 	TEMP, (0<<ADTS2)|(0<<ADTS1)|(0<<ADTS0)
		sts 	ADCSRB, TEMP

		ldi 	TEMP, (0<<CS02)|(1<<CS01)|(1<<CS00)
		out 	TCCR0B, TEMP

		ldi 	TEMP, (1<<ADEN)|(1<<ADSC)|(0<<ADATE)|(1<<ADIF)|(1<<ADIE)|(0<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
		sts 	ADCSRA, TEMP

		ldi 	TEMP, high(20000)
		sts 	ICR1H, TEMP
		ldi 	TEMP, low(20000)
		sts 	ICR1L, TEMP

		ldi 	TEMP, high(1500)
		sts 	OCR1AH, TEMP
		ldi 	TEMP, low(1500)
		sts 	OCR1AL, TEMP

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

ReadADC:
		lds 	ADCLow, ADCL
		mov 	PWML, ADCLow
		lds 	ADCHigh, ADCH
		mov 	PWMH, ADCHigh
		add 	PWML, OffL
		adc 	PWMH, OffH
		sts 	OCR1AH, PWMH
		sts 	OCR1AL, PWML
		reti

OVF0isr:
		ldi 	TEMP, (1<<ADEN)|(1<<ADSC)|(0<<ADATE)|(1<<ADIF)|(1<<ADIE)|(0<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
		sts 	ADCSRA, TEMP
		reti		














		




