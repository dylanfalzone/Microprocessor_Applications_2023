;******************************************************************************
;  File name: lab2_2.asm
;  Author: Dylan Falzone
;  Last Modified On: 11 Feb 2023
;  Purpose: toggle an IO port pin every 10ms
;
;******************************************************************************

.include "ATxmega128a1udef.inc"

;*********************MAIN*********************
.cseg
.org 0x0
	rjmp MAIN
	


.org 0x100
MAIN: 
	ldi r16, ((0x3fff>>0) & 0xff)
	sts CPU_SPL, r16
	ldi r16, ((0x3fff>>8) & 0xff)
	sts CPU_SPH, r16

	ldi r18, 0x00
	ldi r17, 0xff

	sts PORTJ_OUT, r18 ;set all outputs to 0
	sts PORTJ_DIR, r17 ;set all pins in portJ to output
	ldi r20, 5
LOOP: 
	rcall DELAY_X_10MS


	sts PORTJ_OUTTGL, r17 ;toggle output 








rjmp loop

DONE:
rjmp DONE


;*********************SUBROUTINE1**********************************
;  NAME: DELAY_10MS
;  Purpose: DELAY 10 MILLISECONDS
;  INPUT(S): N/A
;  OUTPUT(S): N/A
;
;******************************************************************
DELAY_10MS:
	;delaying 10ms is the equivalent of 20,000 clock cycles at 2MHZ
	push r16
	push r17
	ldi r17, 0x00
	ldi r16, 0x00

	LOOP2: ;this should run 20x creating a total delay of 20,000 cycles or 10ms
		LOOP1:	;this should produce 1020 clock cycles of delay
			inc r16
			cpi r16, 0xff
			brne LOOP1
			rjmp LOOP1done
		LOOP1DONE:
		inc r17
		cpi r17, 20
		brne LOOP2


	pop r17
	pop r16
	ret

;*********************SUBROUTINE2**********************************
;  NAME: DELAY_X_10MS
;  Purpose: DELAY 10 MILLISECONDS
;  INPUT(S): X (number of delays) stored in r20
;  OUTPUT(S): N/A
;
;******************************************************************
DELAY_X_10MS:
	push r19
	mov r19, r20
	push r20

	DELAYXLOOP:
	rcall DELAY_10MS
	dec r19
	cpi r19, 0
	breq DELAYXLOOPDONE
	rjmp DELAYXLOOP


	DELAYXLOOPDONE:
	pop r20 
	pop r19
	ret