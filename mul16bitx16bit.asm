; Demo multiply 2 16 bit values to get 32 bit result
; Multiplying 2 8 bit registers puts 16 bit result in R1..R0
; This demo accumulates results in R25..R22
; Source:  https://github.com/harrimand/AVR/blob/master/mul16bitx16bit.asm

.nolist
.include "m328pdef.inc"
.list

.equ	MUL1 = $FF08 ;$5F2A
.equ	MUL2 = $FFA1 ;$4721

.def	TEMP = R16
.def	m1H = R19
.def	m1L = R18
.def	m2H = R21
.def	m2L = R20
.def	res3 = R25	; MSB of 32 bit result (4 bytes)
.def	res2 = R24
.def	res1 = R23
.def	res0 = R22	; LSB of 32 bit result
.def	ZERO = R15

.ORG	$0000
		rjmp	RESET
.ORG	INT_VECTORS_SIZE
RESET:

		ldi 	M1H, high(MUL1)
		ldi 	M1L, low(MUL1)
		ldi 	M2H, high(MUL2)
		ldi 	M2L, low(MUL2)
		clr 	ZERO
		rcall	mul16

MAIN:
		nop
		nop
		nop
		rjmp	MAIN

mul16:
		clr 	res3
		clr 	res2
		mul 	M1L, M2L	; Result to R1..R0
		mov 	res0, R0
		mov 	res1, R1
		mul 	M1L, M2H
		add 	res1, R0
		adc 	res2, R1
		mul 	M1H, M2L
		add 	res1, R0
		adc 	res2, R1
		adc 	res3, ZERO
		mul 	M1H, M2H
		add 	res2, R0
		adc 	res3, R1
		ret

;		 H  L
;M2		47 21
;M1		5F 2A
; 		------
;		05 6A
;	     0B A6
;	     0C 3F
;         1A 59
;	 -------------
;	  1A 70 EA 6A
;
