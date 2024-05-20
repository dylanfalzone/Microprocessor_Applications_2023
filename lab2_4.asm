;*************************************************************************************
;  File name: lab2_4.asm
;  Author: Dylan Falzone
;  Last Modified On: 11 Feb 2023
;  Purpose: an LED timing program where:
;			Begin in EDIT mode where you can activate leds with dip switches 
;			and store the configuration to memory using led backpack switch s1,
;			or move to play mode by pressing s2
;			
;			in Play mode, leds will rotate through their frames assigned in edit mode
;			at a rate of 5HZ. Return to edit mode with switch s1 on the MB backpack.
;			
;			On a more technical level, we have EDITMODE and PLAYMODE as loops in main,
;			and we use subroutines to initialize our IO, start time counter, debounce,
;			and refresh our LEDs in playmode. 
;***************************************************************************************
.include "ATxmega128a1udef.inc"

.equ F = 2000000
.equ PRE = 64
.equ PD = 2
.equ PDDIV = 10


;***************************FRAME_TABLE***************************************
.dseg
.org 0x2000
FRAME_TABLE:


;***************************ENTRY POINT****************************
.cseg
.org 0x0
	rjmp MAIN

.org 0x100
;******************************MAIN**********************************************
MAIN: 
;initialize stack
ldi r16, ((0x3fff>>0) & 0xff)
sts CPU_SPL, r16
ldi r16, ((0x3fff>>8) & 0xff)
sts CPU_SPH, r16

;intitialize IO, point Y to table
rcall IO_INIT
ldi YL, LOW(FRAME_TABLE)
ldi YH, HIGH(FRAME_TABLE)
ldi r24, 0x00

	EDITMODE:	;***********EDITMODE*********************************************
	;connect DIPS to LEDs
	lds r17, PORTA_IN	;DIPs in
	sts PORTC_OUT, r17	;LEDs out
	lds r18, PORTF_IN	;BUTTONs in
	


	;s1 pressed, go to debouncing
	sbrs r18, 2
	rjmp DEBOUNCING
		
	;s2 pressed, go to playmode
	sbrs r18, 3
	rjmp PLAYMODE
	rjmp EDITMODE

		;wait .6s and check if button still held, then store frame to table
		DEBOUNCING:
		rcall DEBOUNCER
		sbrs r18, 2
		st Y+, r17
		inc r24	;this is used in playmode to tell how many frames we should have in the table
		rjmp EDITMODE



	PLAYMODE:	;***********PLAYMODE*********************************************
	;point X to table, create a counter
	ldi XL, LOW(FRAME_TABLE)
	ldi XH, HIGH(FRAME_TABLE)
	ldi r25, 0x00	;used to increment through table
	lds r18, PORTE_IN ;	MB button in

	PLAYLOOP:
	rcall REFRESHANIMATION ;code past this point is run at a frequency of 5Hz

	;MBs1 pressed, go to editmode
	sbrs r18, 0
	rjmp EDITMODE

	;increment through each frame on a loop
	ld r17, X+	;X points to current value in table
	sts PORTC_OUT, r17	;output frames to LEDs
	inc r25
	cp r25, r24
	breq PLAYMODE	;once we have seen each frame once, start again
	rjmp PLAYLOOP	;if we havent seen each frame yet, keep going


DONE:
rjmp DONE



;*********************SUBROUTINE1**********************************
;  NAME: IO_INIT
;  Purpose: INITIALIZE NECESSARY IO PORTS
;  INPUT(S): N/A
;  OUTPUT(S): N/A
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

pop r16
ret

;*********************SUBROUTINE2**********************************
;  NAME: TC_INIT
;  Purpose: start the 5Hz clock 
;  INPUT(S): N/A
;  OUTPUT(S): N/A
;
;******************************************************************
TC_INIT:
push r20

ldi r20, low((F*PD)/(PDDIV*PRE)) ; 
sts TCC0_PER, r20
ldi r20, high((F*PD)/(PDDIV*PRE))
sts (TCC0_PER+1), r20

ldi r20, TC_CLKSEL_DIV64_gc	; start the clock!
sts TCC0_CTRLA, r20


pop r20
ret


;*********************SUBROUTINE3**********************************
;  NAME: DEBOUNCER
;  Purpose: wait 0.6s, then return to program
;  INPUT(S): N/A
;  OUTPUT(S): N/A
;
;******************************************************************
DEBOUNCER:
push r16
push r19
push r21
rcall TC_INIT ;start the clock
ldi r21, 0x00
DLOOPDELAY:
	lds r19, TCC0_INTFLAGS ;load r19 with intflag
	sbrs r19, 0	;skip next instruction if intflag is set
	rjmp DLOOPDELAY ;intflag isnt set so we keep looping
		
	;reset the overflow
	ldi r19, TC0_OVFIF_bm	;load r19 with the bm to reset overflow
	sts TCC0_INTFLAGS, r19	;reset overflow

	;run the 0.2s count 3 times to get a 0.6s debounce time.
	inc r21		
	cpi r21, 3
	brne DLOOPDELAY
	;return to program
pop r21
pop r19
pop r16
ret

;*********************SUBROUTINE4**********************************
;  NAME: REFRESHANIMATION
;  Purpose: wait .2s, then return to program
;  INPUT(S): N/A
;  OUTPUT(S): N/A
;
;******************************************************************
REFRESHANIMATION:
push r16
push r19
rcall TC_INIT ;start the clock
RLOOPDELAY:

	lds r19, TCC0_INTFLAGS ;load r19 with intflag
	sbrs r19, 0	;skip next instruction if intflag is set
	rjmp RLOOPDELAY ;intflag isnt set so we keep looping
		
	;reset the overflow
	ldi r19, TC0_OVFIF_bm	;load r19 with the bm to reset overflow
	sts TCC0_INTFLAGS, r19	;reset overflow
	;return to program
pop r19
pop r16
ret