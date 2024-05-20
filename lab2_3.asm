;******************************************************************************
;  File name: lab2_3.asm
;  Author: Dylan Falzone
;  Last Modified On: 11 Feb 2023
;  Purpose: toggle I/O port pin every 60s
;
;******************************************************************************

.include "ATxmega128a1udef.inc"

.equ F = 2000000
.equ PRE = 64
.equ PD = 1
.equ PDDIV = 1


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
	ldi r19, 0xff
	

LOOP: 
	rcall DELAY ;start the clock
	ldi r21, 0
	LOOPDELAY:
	lds r19, TCC0_INTFLAGS ;load r19 with intflag
	sbrs r19, 0	;skip next instruction if intflag is set
	rjmp LOOPDELAY ;intflag isnt set so we keep looping
		
	ldi r19, TC0_OVFIF_bm	;load r19 with the bm to reset overflow
	sts TCC0_INTFLAGS, r19	;reset overflow
	inc r21
	cpi r21, 60
	brne LOOPDELAY

	sts PORTJ_OUTTGL, r17 ;toggle output 







rjmp LOOP

DONE:
rjmp DONE

;*********************SUBROUTINE2**********************************
;  NAME: DELAY_X_10MS
;  Purpose: DELAY
;  INPUT(S): X (number of ms to delay)
;  OUTPUT(S): N/A
;
;******************************************************************
DELAY:
	push r20

	ldi r20, low((F*PD)/(PDDIV*PRE)) ; 
	sts TCC0_PER, r20
	ldi r20, high((F*PD)/(PDDIV*PRE))
	sts (TCC0_PER+1), r20

	ldi r20, TC_CLKSEL_DIV64_gc
	sts TCC0_CTRLA, r20


	pop r20 
	ret