//  Using Timer 1 Pulse Width Modulation (PWM) to blink LEDs at 1 blink per second.
//  OC1A Pin 6 on approximately .1 seconds per blink
//  OC1B Pin 3 on approximately .5 seconds per blink

.nolist
.include "tn85def.inc"
.list

.def    TEMP = R16
.def	envCount = R17


.org 	$0000
rjmp    RESET
.org	OVF1addr
		rjmp	ISR1ovf
.org 	INT_VECTORS_SIZE


RESET:
    ldi     TEMP, (1<<PB4)|(1<<PB1)
    out     DDRB, TEMP  //  Pin 3 PB4 and Pin 6 PB1 Output

    ldi     TEMP, 25  // 244 * 4096 * 1 uS = .999 Second Period (Seconds per cycle)
    out     OCR1C, TEMP  //Timer resets when matching OCR1C value.

    ldi     TEMP, 12   // On Time = 24 / 244 Seconds  Approximately .1 seconds per blink
    out     OCR1A, TEMP

    ldi     TEMP, 12    // On Time = 122 / 244 Seconds  Approximately .5 Seconds per blink
    out     OCR1B, TEMP

    ldi     TEMP, (1<<PWM1B)|(1<<COM1B1)|(0<<COM1B0)
    out     GTCCR, TEMP  // PWM Enabled.  OC1B on when timer is reset.  Of when timer matches OCR1B
    
    ldi     TEMP, (1<<PWM1A)|(1<<COM1A1)|(0<<COM1A0)|(0<<CS13)|(0<<CS12)|(0<<CS11)|(1<<CS10) //MCU clk / 4096
    out     TCCR1, TEMP  // PWM Enabled.  OC1A on when timer is reset.  Of when timer matches OCR1A

    ldi     TEMP, (1<<SE)
    out     MCUCR, TEMP    // Sleep Mode 0 (Idle) Enabled

	ldi 	TEMP, (1<<TOIE1)
	out 	TIMSK, TEMP

	clr 	envCount

    sei  // Global Interrupt Enable (Optional on this program)

MAIN:
    sleep  // Sleeping.  Program counter stopped.  Timer and PWM out to LEDs still works.
    nop
    rjmp    MAIN


ISR1ovf:  // Configure 40KHz LED pulse envelope.  70 Pulses On - 30 Pulses off.
	inc 	envCount
	cpi 	envCount, 70
	brne	ENV_ON
    ldi     TEMP, (1<<PWM1B)|(0<<COM1B1)|(0<<COM1B0)
    out     GTCCR, TEMP  // PWM Enabled.  OC1B on when timer is reset.  Of when timer matches OCR1B
    
    ldi     TEMP, (1<<PWM1A)|(0<<COM1A1)|(0<<COM1A0)|(0<<CS13)|(0<<CS12)|(0<<CS11)|(1<<CS10) //MCU clk / 4096
    out     TCCR1, TEMP  // PWM Enabled.  OC1A on when timer is reset.  Of when timer matches OCR1A
	cbi 	PORTB, PB4
	cbi 	PORTB, PB1
  
ENV_ON:
	cpi 	envCount, 100
	brne	CYCLE
	
    ldi     TEMP, (1<<PWM1B)|(1<<COM1B1)|(0<<COM1B0)
    out     GTCCR, TEMP  // PWM Enabled.  OC1B on when timer is reset.  Of when timer matches OCR1B
    
    ldi     TEMP, (1<<PWM1A)|(1<<COM1A1)|(0<<COM1A0)|(0<<CS13)|(0<<CS12)|(0<<CS11)|(1<<CS10) //MCU clk / 4096
    out     TCCR1, TEMP  // PWM Enabled.  OC1A on when timer is reset.  Of when timer matches OCR1A
	clr 	envCount
CYCLE:
	reti
