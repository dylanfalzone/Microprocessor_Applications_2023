;******************************************************************************
; File name: lab2_3.asm
; Author: Dylan Falzone
; Last Modified On: 11 Feb 2023
; Purpose: use switches to make an 8bit number.
;		   press SLB s1 to assign this to the duty cycle of RED
;		   press SLB s2 to assign this to the duty cycle of BLUE
;		   press MB s1 to assign this to the duty cycle of GREEN 
;
;******************************************************************************



.cseg
.org 0x0
	rjmp MAIN


.org 0x100
MAIN: ;***********MAIN*********************************************

;initialize stack
ldi r16, ((0x3fff>>0) & 0xff)
sts CPU_SPL, r16
ldi r16, ((0x3fff>>8) & 0xff)
sts CPU_SPH, r16


;initialize clock, ports
rcall IO_INIT
rcall TC_INIT

ldi r30, 0x00

	LOOP1:
	lds r17, PORTA_IN ;DIPs to r17
	sts PORTC_OUT, r17 ;r17 to LEDs
	lds r18, PORTF_IN ;SLB BUTTONs to r18
	lds r19, PORTE_IN ; MB button to r19
	ldi r23, 0x00
	lds r24, PORTA_IN ;DIPs inverse to r24 
	com r24

	;s1 pressed (red)
	sbrs r18, 2
	rcall RED
	
	;s2 pressed (blue)
	sbrs r18, 3
	RCALL BLUE

	;MBs1 pressed (green)
	sbrs r19, 0
	RCALL GREEN



	LOOP2:
	ldi r25, 0x00
	lds r20, TCD0_INTFLAGS

	;if flag0 is set, jump to FLAG0
	sbrc r20, 0
	rjmp FLAG0

	;if flag4 (red) is set, call redset
	sbrc r20, 4
	rcall REDSET

	;turn off any LEDs that have reached their period
	sts PORTD_OUTSET, r20
	sts TCD0_INTFLAGS, r20











	rjmp LOOP1

	FLAG0:
	;CLock has restarted, turn off all flags, turn on all LED's
	ldi r21, 0xff
	sts TCD0_INTFLAGS, r21
	ldi r21, 0x00
	sts PORTD_OUT, r21
	rjmp LOOP1




DONE:
rjmp DONE







;*********************SUBROUTINE1**********************************
; NAME: IO_INIT
; Purpose: INITIALIZE NECESSARY IO PORTS
; INPUT(S): N/A
; OUTPUT(S): N/A
;
;******************************************************************
IO_INIT:
push r16

;init portc (LEDs)
ldi r16, 0xff
sts PORTC_OUT, r16 ;set all outputs to 1 (leds off)
sts PORTC_DIR, r16 ;set all pins in portc to output

;init porta (DIPs)
ldi r16, 0
sts PORTA_DIR, r16 ;set all pins in portA to input

;init portF (s1,s2 SLB)
ldi r16, 0 
sts PORTF_DIR, r16 ;set all pins in portF to input

;init portE (s1, s2 MB)
ldi r16, 0
sts PORTE_DIR, r16 ;set all pins in portE to input

;init portD (RGB)
ldi r16, 0xff
sts PORTD_OUT, r16 ;turn off all leds
ldi r16, 0x00
sts PORTD_DIR, r16 ;set all pins in portD to INPUT (they become output when they get individually assigned)

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
push r20

;init ctrlb for pwm
ldi r20, 0b01110011
sts TCD0_CTRLB, r20

;set PER
ldi r20, 255
sts TCD0_PER, r20
ldi r20, 0x00
sts (TCD0_PER+1), r20

;set PRE, CTRLA
ldi r20, TC_CLKSEL_DIV64_gc
sts TCD0_CTRLA, r20

pop r20 
ret

;*********************SUBROUTINES 3-5**********************************
; NAME: RED,BLUE,GREEN
; Purpose: assign ccx and set pin to output if not already done
; INPUT(S): N/A
; OUTPUT(S): N/A
;
;******************************************************************

	RED:
	push r20
	;set ccx from switch input
	sts TCD0_CCA, r24 
	sts (TCD0_CCA+1), r23 

	;if bit 4 of r30 is not set (if R LED is input, set to out), set it
	sbrs r30, 4
	ldi r20, 0b00010000
	sbrs r30, 4
	add r30, r20
	sts PORTD_DIR, r30 ;set portD to output (just the Red bit 4)

	pop r20
	ret


	GREEN:
	push r20
	;set ccx from switch input
	sts TCD0_CCB, r24 
	sts (TCD0_CCB+1), r23 

	;if bit 5 of r30 is not set (if G LED is input, set to out), set it
	sbrs r30, 5
	ldi r20, 0b00100000
	sbrs r30, 5
	add r30, r20
	sts PORTD_DIR, r30 ;set portD to output (just the GREEn bit 5)

	pop r20
	ret


	BLUE:
	push r20
	;set ccx from switch input
	sts TCD0_CCC, r24 
	sts (TCD0_CCC+1), r23 

	;if bit 6 of r30 is not set (if B LED is input, set to out), set it
	sbrs r30, 6
	ldi r20, 0b01000000
	sbrs r30, 6
	add r30, r20
	sts PORTD_DIR, r30 ;set portD to output (just the Blue bit 6)

	pop r20
	ret

;*********************SUBROUTINES 6-8**********************************
; NAME: RED,BLUE,GREEN SET
; Purpose: clear intflag and turn off LED. 
; INPUT(S): N/A
; OUTPUT(S): N/A
;
;******************************************************************
REDSET:

ret

GREENSET:

ret

BLUESET:

ret