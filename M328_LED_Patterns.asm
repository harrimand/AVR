/* Test program to produce LED sequences on PORTB */

.nolist
.include "M328Pdef.inc"
.list

.def	TEMP = R16
.def	TEMP2 = R17
.def	DATA = R18


.ORG	$0000
		rjmp	RESET
.ORG	INT_VECTORS_SIZE

RESET:
		ldi 	TEMP, high(RAMEND)
		out 	SPH, TEMP
		ldi 	TEMP, low(RAMEND)
		out 	SPL, TEMP
		ldi 	TEMP, $07
		out 	GPIOR0, TEMP	; Flags to control LED sequence 
		ser 	TEMP
		out 	DDRB, TEMP
;------------------------------------
MAIN:
		rcall	kitCar
		out 	PORTB, DATA
;		rcall	DELAY		;Lime commented for simulation
		rjmp	MAIN
;------------------------------------
KitCar:	; Fill display from left
		sbis	GPIOR0, 2
		rjmp	KitCarLeft
		sbis	GPIOR0, 0
		rjmp	LEFTempty
		;Sequence 1_1
		sec
		ror 	DATA
		cpi 	DATA, $FF
		brne	NOTfull_L
		cbi 	GPIOR0, 0
NOTfull_L:
		ret
LEFTempty:	;Sequence 1_2  ; Empty Display from Right
		lsl 	DATA
		brne	NOTempty_L
		sbi 	GPIOR0, 0
		cbi 	GPIOR0, 2
NOTempty_L:
		ret
;---------------------------------
KitCarLeft:	;Sequence 2_1  ; Fill display from Right
		sbis 	GPIOR0, 1
		rjmp	RIGHTempty
		sec
		rol 	DATA
		cpi 	DATA, $FF
		brne	NOTfull_R
		cbi 	GPIOR0, 1
NOTfull_R:
		ret
RIGHTempty:	;Sequence 2_2  ; Empty display from Left
		lsr 	DATA
		brne	NOTempty_R
		sbi 	GPIOR0, 1
		sbi 	GPIOR0, 2
NOTempty_R:
		ret
;-----------------------------------
DELAY:  	; Programmed Delay Loop consumes 1E6 cycles (1 Sec at 1 MHz)
		ldi 	R21, $06
LOOP3:
		ldi 	R20, $D9
LOOP2:
		ldi 	R19, $FF
LOOP1:
		dec 	R19
		brne	LOOP1
		dec 	R20
		brne	LOOP2
		dec 	R21
		brne	LOOP3
		ldi 	R19, $0F
TRIM:
		dec 	R19
		brne	TRIM
		nop
		ret
;------------------------------------
