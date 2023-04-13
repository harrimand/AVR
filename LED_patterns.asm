;Darrell Harriman
;Testing AVR download
; Reading a table of data from flash memory and outputting it to PORTB on Timer0 Overflow Interrupt

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
		rjmp	ReadTable
		; rjno	KitFun
.ORG	INT_VECTORS_SIZE
;------------------------------------------------------------------
RESET:
		ldi 	TEMP, high(RAMEND)  ; Stack pointer at RAMEND
		out	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP

		ser 	TEMP 		;PORTB all pins output
		out 	DDRB, TEMP

		clr 	COUNT

		clr	TEMP
		mov	kit, TEMP

		ldi 	ZH, high(DATA<<1)
		ldi 	ZL, low(DATA<<1)
		ldi 	YH, high(DATAend<<1)
		ldi 	YL, low(DATAend<<1)

		ldi 	TEMP, (1<<TOIE0)  ; Timer 0 Overflow Interrupt Enable
		sts  	TIMSK0, TEMP

		ldi 	TEMP, (1<<CS02)|(0<<CS01)|(1<<CS00)  ; MCUclk / 1024
		out 	TCCR0B, TEMP

		ldi 	TEMP, (1<<SE)  ; Sleep mode 0 (Idle) enabled.
		out 	SMCR, TEMP

		sei
;------------------------------------------------------------------
MAIN:
		nop
		nop
		sleep   ; Sleep and wait for interrupt to wake up
		nop
		rjmp	MAIN

T0ovf:  ;Timer 0 Overflow Interrupt Service Routine
		ldi 	TEMP, $80
		out 	TCNT0, TEMP 
		inc 	COUNT
		out 	PORTB, COUNT
		reti
;------------------------------------------------------------------
KitFun:
		push		TEMP
		ldi		TEMP, $C0
		out		TCNT0, TEMP
		tst		kit
		brne		noInit
		ser		kitSource
		in		TEMP, GPIOR0
		ldi		TEMP2, $01
		eor		TEMP, TEMP2
		out		GPIOR0, TEMP
		ser		kitSource
noInit:
		in		TEMP, GPIOR0
		sbrs		TEMP, 0
		rjmp		ShiftRight
		rol		kitSource
		rol		kit
		rjmp		Return
ShiftRight:
		ror		kitSource
		ror		kit
Return:
		out		PORTB, kit
		pop		TEMP
		reti
;------------------------------------------------------------------
ReadTable:	
		push		TEMP
		lpm		TEMP, Z+
		cp		ZL, YL
		cpc		ZH, YH
		brne		NotEnd
		ldi		ZH, high(DATA<<1)
		ldi		ZL, low(DATA<<1)
NotEnd:
		out		PORTB, TEMP
		pop 		TEMP
		reti
ProgEnd:
;------------------------------------------------------------------

.ORG ProgEnd + 0x40/2 - ((ProgEnd + 0x40/2) % 16)

DATA:
.db		0x18, 0x3c, 0x7e, 0xff, 0xff, 0xe7, 0xc3, 0x81
.db		0x80, 0x81, 0xc1, 0xc3, 0xe3, 0xe7, 0xf7, 0x7f
.db		0x7e, 0x3e, 0x3c, 0x1c, 0x18, 0x8, 0x80, 0x40
.db		0x20, 0x10, 0x8, 0x4, 0x2, 0x43, 0x23, 0x13
.db		0xb, 0x7, 0x87, 0x47, 0x17, 0xf, 0x8f, 0x4f
.db		0x2f, 0x1f, 0x9f, 0x3f, 0xbf, 0x7f, 0xff, 0xfe
.db		0xfd, 0xfc, 0xf9, 0xf8, 0xf4, 0xf2, 0xf1, 0xf0
.db		0xe8, 0xe2, 0xe1, 0xe0, 0xd0, 0xc8, 0xc4, 0xc2
.db		0xc0, 0xa0, 0x90, 0x88, 0x84, 0x82, 0x81, 0x40
.db 		0x20, 0x10, 0x8, 0x4, 0x2, 0x1, 0xff, 0x0
.db     	0xff, 0x0, 0xff, 0x0, 0xff, 0x7f, 0xbf, 0xdf
.db		0xef, 0xf7, 0xfb, 0xfd, 0x7e, 0xbe, 0xde, 0xee
.db		0xf6, 0xfa, 0xfc, 0xbc, 0xdc, 0xec, 0xf4, 0xf8
.db		0x78, 0xb8, 0xe8, 0xf0, 0x70, 0xb0, 0xd0, 0xe0
.db		0x60, 0xc0, 0x40, 0x80, 0x0, 0x0, 0x0, 0xff
.db		0x18, 0xc3, 0x42, 0x66, 0xe7, 0xa5, 0x24, 0xbd
.db		0xff, 0x7e, 0x5a, 0xdb, 0x99, 0x18, 0x66, 0x99
.db		0x66, 0x99, 0x66, 0x99, 0xff, 0x7e, 0xbd, 0xdb
.db		0xe7, 0x66, 0xa5, 0xc3, 0x81, 0x0, 0xff, 0x0
DATAend:
