
; Run Function if both pins PB3 and PB4 are high.

.nolist
.include "m328pdef.inc"
.list

.def	TEMP = R16
.def	TEMP2 = R17

.ORG	$0000
		rjmp	RESET
.ORG	INT_VECTORS_SIZE
RESET:

		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, LOW(RAMEND)
		out 	SPL, TEMP

		cbi 	DDRB, PB3
		cbi 	DDRB, PB4
		ldi 	TEMP, (1<<PB4)|(1<<PB3)
		out 	PORTB, TEMP

MAIN:	

		rcall	checkPins3 ;Select checkPins0, 1, or 2
		rjmp	MAIN

;Method 1
checkPins0:
		sbis	PINB, PB3
		rjmp	MAIN
		sbic	PINB, PB4
		rcall	FUN
		ret

;Method 2
checkPins1:
		in  	TEMP, PINB
		andi	TEMP, $18
		cpi 	TEMP, $18
		breq	NoFun1
		rcall	FUN
NoFun1:
		ret

;Method 3
checkPins2:
		in  	TEMP, PINB
		andi	TEMP, $18
		cpi 	TEMP, $18
		in  	TEMP, SREG
		sbrc	TEMP, SREG_Z
		rcall	FUN
NoFun2:
		ret

;Method4
CheckPins3:
		in  	TEMP, PINB ; Read PINB
		andi 	TEMP, $18  ; Mask out all but bits 3 and 4
		mov 	TEMP2, TEMP	; Copy Register
		lsr 	TEMP2		; Shift Right Register
		and 	TEMP, TEMP2 ; Bitwise AND TEMP and TEMP2
		;  Bit3 set if both bit 3 in Temp and TEMP2 are set
		sbrc	TEMP, PB3   ; Skip rcall if bit 3 not set
		rcall	FUN
		ret

FUN:
		nop
		nop	
		ret
