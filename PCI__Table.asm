
; Select a function and decoded seven segment output
; using Pin Change Interrupt on PORTA3..0
; Output 7 segment to PORTB using selected function

.nolist
.include "m1284Pdef.inc"
.include "clrSRAM.asm"
.list

.def 	TEMP = R16
.def 	bitCount = R18
.def	sevSegOut = R20
.equ	SevSegDecode = SRAM_START + $10

.ORG	$0000
		rjmp	RESET
.ORG	PCI0addr
		rjmp 	FindButton
.ORG	INT_VECTORS_SIZE
RESET:
clrSRAM
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP

		eor 	TEMP, TEMP
		out 	DDRA, TEMP      ;PortA3..0 INPUT
		ldi 	TEMP, $0F       ; Pull-Ups on Bits 3..0
		out 	PORTA, TEMP

		; To simulate Pull-Ups set PINA 3..0 High
		; Change Pin to Low after global interrupts
		; enabled to simulate button press

		ser 	TEMP
		out 	DDRB, TEMP      ;PortB7..0 OUTPUT

		ldi 	TEMP, $0F       ;Pins 3..0 PCI enabled
		sts 	PCMSK0, TEMP		

		ldi 	TEMP, (1<<PCIE0);
		sts 	PCICR, TEMP     ; PCI0 Enabled

		rcall	CopyTable
		
		sei
				
MAIN:
		nop
		nop
		nop
		rjmp	MAIN


FindButton:
        push    TEMP
        push    bitCount
        push    sevSegOut
		in  	TEMP, PINA
		andi	TEMP, $0F       ;Mask out bits 7..4		
		                        ; Return if no button pressed
		cpi 	TEMP, $0F
		brne	Pressed
		reti
Pressed:
		clr 	bitCount
NextBit:  ;Logical Shift Right until carry clear and count shifts
		inc 	bitCount
		lsr 	TEMP
		brcs	NextBit
		dec 	bitCount
		ldi 	XH, high(SevSegDecode)
		ldi 	XL, low(SevSegDecode)
		add 	XL, bitCount
		ld  	sevSegOut, X	; Get decoded Seven Segment Data

		lsl 	bitCount        ; Double bitCount to index words.

		ldi 	ZH, high(FunAddresses<<1) ;Load function table base address
		ldi 	ZL, low(funAddresses<<1)
		add 	ZL, bitCount    ; add offset to select function address
		lpm 	XL, Z+          ; Load address into X using Z
		lpm 	XH, Z
		movw	ZH:ZL, XH:XL    ; Copy X to Z
		icall	                ; Call function at address in Z
        pop     sevSegOut
        pop     bitCount
        pop     TEMP 
		reti

CopyTable:
		ldi 	ZH, high(SevSegTable<<1)
		ldi 	ZL, low(SevSegTable<<1)
		ldi 	YH, high(SevSegEnd<<1)
		ldi 	YL, low(SevSegEnd<<1)
		ldi  	XH, high(SRAM_START + $10)
		ldi 	XL, low(SRAM_START + $10)
CopyNext:
		lpm 	TEMP, Z+
		st  	X+, TEMP
		cp  	YL, ZL
		cpc 	YH, ZH
		brne	CopyNext
		ret

SevSegTable:  ;Common Cathode outputs for 0..9
.db		$3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F
SevSegEnd:

FunAddresses:
.dw 	Fun0, Fun1, Fun2, Fun3
FunEnd:
	
Fun0:
	nop
	out PORTB, sevSegOut
	nop
	ret
Fun1:
	nop
	out PORTB, sevSegOut
	nop
	ret
Fun2:
	nop
	out PORTB, sevSegOut
	nop
	ret
Fun3:
	nop
	out PORTB, sevSegOut
	nop
	ret
