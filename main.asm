;************************************************************************
;  File name: lab1.asm
;  Author:  Dylan Falzone
;  Last Modified On: 3 Feb 2023
;  Description: To filter data stored within a predefined input table 
;     based on a set of given conditions and store 
;     a subset of filtered values into an output table.
;*********************************INCLUDES*******************************
.include "ATxmega128a1udef.inc"
;***********END OF INCLUDES******************************
;*********************************EQUATES********************************
; potentially useful expressions

.equ NULL = 0
.equ ThirtySeven = 3*7 + 37/3 - (3-7)  ; 21 + 12 + 4
;***********END OF EQUATES*******************************
;***********MEMORY CONFIGURATION*************************
; program memory constants (if necessary)
.cseg
.org 0xF070
IN_TABLE:
.db 195,',',0b00100010,0xAE,0x21,33,041,205,'/',0x8A,0b10001101,0216,0x00,0b10101110
.db NULL
; label below is used to calculate size of input table
IN_TABLE_END:

; data memory allocation (if necessary)
.dseg
; initialize the output table starting address
.org 0x3456
OUT_TABLE:
.byte (IN_TABLE_END - IN_TABLE)
;***********END OF MEMORY CONFIGURATION***************
;***********MAIN PROGRAM*******************************
.cseg
; configure the reset vector 
;	(ignore meaning of "reset vector" for now)
.org 0x0
	rjmp MAIN

; place main program after interrupt vectors 
;	(ignore meaning of "interrupt vectors" for now)
.org 0x100
MAIN:

ldi ZL, BYTE3(IN_TABLE<<1)
out CPU_RAMPZ, ZL
ldi ZH, BYTE2(IN_TABLE<<1)
ldi ZL, BYTE1(IN_TABLE<<1)

ldi YL, LOW(OUT_TABLE)
ldi YH, HIGH(OUT_TABLE)

; point appropriate indices to input/output tables (is RAMP needed?)
	;no ramp needed for this part because table is within range.

; loop through input table, performing filtering and storing conditions
LOOP:
	; load value from input table into an appropriate register
	elpm r16, Z+
	ldi r18, 0x0
	cpse r16, r18
		rjmp CHECK_1
		rjmp DONE
	; determine if the end of table has been reached (perform general check)
	
	; if end of table (EOT) has been reached, i.e., the NULL character was 
	; encountered, the program should branch to the relevant label used to
	; terminate the program (e.g., DONE)
	
	; if EOT was not encountered, perform the first specified 
	; overall conditional check on loaded value (CONDITION_1)
CHECK_1:


	bst r16,7
	brts CHECK_11
	rjmp FAILED_CHECK1
	; check if the CONDITION_1 is met (bit 7 of # is set); 
	;   if not, branch to FAILED_CHECK1

CHECK_11:


	; since the CONDITION_1 is met, perform the specified operation
	;   (divide # by 2)
	LSR r16
	ldi r19, 170
	cp r16, r19
	BRLO LESS_THAN_170

	; check if CONDITION_1a is met (result < 170); if so, then 
	;   jump to LESS_THAN_170; else store nothing and go back to LOOP
	
	rjmp LOOP

LESS_THAN_170:
	
	

	subi r16, 20
	st Y+, r16
	
	; subtract 20 and store the result
	rjmp LOOP
	
FAILED_CHECK1:
	; since the CONDITION_1 is NOT met (bit 7 of # is not set, 
	;    i.e., clear), perform the second specified operation 
	;    (multiply by 2 [unsigned])
	
	LSL r16
	ldi r20, 85
	cp r16, r20
	BRSH GREATER_EQUAL_85

	; check if CONDITION_2b is met (result >= 85); if so, jump to
	;    GREATER_EQUAL_85 (and do the next specified operation);
	;    else store nothing and go back to LOOP	
	

	rjmp LOOP
	
GREATER_EQUAL_85:

	subi r16, 15
	st Y+, r16

	; subtract 15 and store the result 
	
	;go back to LOOP
	rjmp LOOP
	
; end of program (infinite loop)
DONE: 
	rjmp DONE
;***********END OF MAIN PROGRAM **********************