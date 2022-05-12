

; Test Blinking Lights program for Atmega 328P

.nolist
.include "M328Pdef.inc"
.list

.def TEMP = R16
.def DATA = R15

.ORG	$0000
		rjmp	RESET

.ORG	INT_VECTORS_SIZE

RESET:

	ldi 	TEMP, high(RAMEND)
	out 	SPH, TEMP
	ldi 	TEMP, low(RAMEND)
	out 	SPL, TEMP

	ldi 	TEMP, $FF
	out 	DDRB, TEMP
	ldi 	TEMP, $F8
	mov 	DATA, TEMP
	out 	PORTB, TEMP

MAIN:
	rcall	Delay
	rcall	ROTATE_R
	out 	PORTB, DATA
	rjmp	MAIN


DELAY:
	ldi 	R19, $01
Loop1:
	ldi		R18, $82
Loop2:
	ldi		R17, $FF
Loop3:
	dec		R17
	brne	Loop3
	dec 	R18
	brne 	Loop2
	dec 	R19
	brne	Loop1
ret

ROTATE_R:
	bst 	DATA, 0
	lsr 	DATA
	bld 	DATA, 7
	ret

ROTATE_L:
	bst 	DATA, 7
	lsl 	DATA
	bld 	DATA, 0
	ret

	

