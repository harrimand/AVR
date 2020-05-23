
; Debounce Macro

; deBounce PortInput, PinMask, numDebounces

.MACRO deBounce

.UNDEF	TEMP
.UNDEF	TEMPH
.UNDEF	COUNTER

.def	TEMP2 = R16
.def	COUNT = R17
.def	pinMask = R18 
.def	input = R20

		push TEMP2
		push COUNT
		push pinMask
		push input

dbStart:
		in  	TEMP2, @0
		andi	TEMP2, @1
		ldi 	COUNT, @2
nextRead:
		in  	input, @0
		andi	input, @1
		cp  	TEMP2, input
		brne	dbStart
		dec 	COUNT
		brne	nextRead
		pop 	input
		pop 	pinMask
		pop 	COUNT
		pop 	TEMP2

.UNDEF	TEMP2
.DEF	TEMP = R16
.UNDEF	COUNT
.DEF	TEMPH = R17
.UNDEF	pinMask
.DEF	COUNTER = R18
.UNDEF	input

.ENDMACRO



		
