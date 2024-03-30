
; Pin Change Interrupt on PORTA3..0
; Output 7 segment to PORTB

.nolist
.include "m1284Pdef.inc"
.list

.def 	TEMP = R16
.def 	bitCount = R18

.ORG	$0000
		rjmp	RESET
.ORG	PCI0addr
		rjmp 	FindButton
.ORG	INT_VECTORS_SIZE
RESET:
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP

		eor 	TEMP, TEMP
		out 	DDRA, TEMP  ;PortA3..0 INPUT
		ser 	TEMP
		out 	DDRB, TEMP  ;PortB7..0 OUTPUT

		ldi 	TEMP, $0F ;Pins 3..0 PCI enabled
		sts 	PCMSK0, TEMP		

		ldi 	TEMP, (1<<PCIE0);
		sts 	PCICR, TEMP ; PCI0 Enabled

		rcall	CopyTable
		
		sei
				
MAIN:
		nop
		nop
		nop
		rjmp	MAIN


FindButton:
		in  	TEMP, PINA
		andi	TEMP, $0F ;Mask out bits 7..4		
		clr 	bitCount
NextBit:
		inc 	bitCount
		lsr 	TEMP
		brcs	NextBit
		dec 	bitCount
		ldi 	XH, high(SRAM_START + $10)
		ldi 	XL, low(SRAM_START + $10)
		add 	XL, bitCount
		ld  	TEMP, X
		ldi 	ZH, high(FunAddresses)
		ldi 	ZL, low(funAddresses)
		lsl 	bitCount
		add 	ZL, bitCount				
		reti

CopyTable:
		ldi 	ZH, high(SevSeg<<1)
		ldi 	ZL, low(SevSeg<<1)
		ldi 	YH, high(SevSegEnd<<1)
		ldi 	YL, low(SevSegEnd<<1)
		ldi  	XH, high(SRAM_START + $10)
		ldi 	XL, low(SRAM_START + $10)
CopyNext:
		lpm 	TEMP, Z+
		st  	X+, TEMP
		cp  	YL, XL
		cpc 	YH, XH
		brne	CopyNext
		ret

SevSeg:
.db		$3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F
SevSegEnd:

FunAddresses:
.dw 	Fun0, Fun1, Fun2, Fun3
FunEnd:
	
Fun0:
	nop
	out PORTB, TEMP
	nop
	ret
Fun1:
	nop
	out PORTB, TEMP
	nop
	ret
Fun2:
	nop
	out PORTB, TEMP
	nop
	ret
Fun3:
	nop
	out PORTB, TEMP
	nop
	ret
