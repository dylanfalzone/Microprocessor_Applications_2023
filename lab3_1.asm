;******************************************************************************
; File name: lab3_1.asm
; Author: Dylan Falzone
; Last Modified On: 17 Feb 2023
; Purpose: Toggle an IO pin every 74ms
;
;******************************************************************************
.include "ATxmega128a1udef.inc"

.cseg
.org 0x00
rjmp MAIN

;place rjmp to ISR at the TCC0 intvector
.org TCC0_OVF_vect
rjmp ISR1


.org 0xFD
MAIN:
 ;init stack
ldi r16, ((0x3fff>>0) & 0xff)
sts CPU_SPL, r16
ldi r16, ((0x3fff>>8) & 0xff)
sts CPU_SPH, r16

;init IO, TC, INTERRUPT
rcall IO_INIT
rcall TC_INIT
rcall INT_INIT
	ldi r17, 0x00

	LOOP:
	sei ;global interrupt somehow is getting turned off somewhere so I need this in the loop.

	;dummy code just so something gets run
	ldi r18, 0x10
	inc r17
	cp r17, r18
	breq LOOP
	rjmp LOOP


;*********************SUBROUTINE1**********************************
; NAME: IO_INIT
; Purpose: INITIALIZE NECESSARY IO PORT
; INPUT(S): N/A
; OUTPUT(S): N/A
;******************************************************************
IO_INIT:
push r16

;set all pins in portJ to output low
ldi r16, 0x00
sts PORTJ_OUT, r16
ldi r16, 0xff
sts PORTJ_DIR, r16

pop r16
ret

;*********************SUBROUTINE2**********************************
; NAME: TC_INIT
; Purpose: start the clock 
; INPUT(S): N/A
; OUTPUT(S): N/A
;
;******************************************************************
TC_INIT:
push r16

;Set period

ldi r16, low((74*2000000)/(1000*8)) 
sts TCC0_PER, r16
ldi r16, high((74*2000000)/(1000*8))
sts (TCC0_PER+1), r16

;start clock
ldi r16, TC_CLKSEL_DIV8_gc ; start the clock!
sts TCC0_CTRLA, r16

pop r16
ret


;*********************SUBROUTINE3**********************************
; NAME: INT_INIT
; Purpose: INITIALIZE INTERRUPT
; INPUT(S): N/A
; OUTPUT(S): N/A
;******************************************************************
INT_INIT:
push r16

;choose high level interrupt
ldi r16, TC_OVFINTLVL_HI_gc
sts TCC0_INTCTRLA, r16

;enable high level interrupts globally
ldi r16, PMIC_HILVLEN_bm
sts PMIC_CTRL, r16

;enable interrupts globally
sei

pop r16
ret




;***********ISR1****************
; Name: ISR1
; Purpose: toggle pin
; Inputs: N/A
; Outputs: N/A
;********************************
ISR1:
push r16
ldi r16, CPU_SREG
push r16

;toggle pins
ldi r16, 0xff
sts PORTJ_OUTTGL, r16


pop r16
sts CPU_SREG, r16
pop r16
reti