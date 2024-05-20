;******************************************************************************
;  File name: lab2_1.asm
;  Author: Dylan Falzone
;  Last Modified On: 11 Feb 2023
;  Purpose: Connect backpack switches to corresponding backpack LEDs. 
;			when switch is closed, LED below it is on.
;
;******************************************************************************

.include "ATxmega128a1udef.inc"

;*********************MAIN*********************
.cseg
.org 0x0
	rjmp MAIN
	


.org 0x100
MAIN: 


;init portc
ldi r16, 0xff
sts PORTC_OUT, r16 ;set all outputs to 1 (leds off)
sts PORTC_DIR, r16 ;set all pins in portc to output

;init porta
ldi r16, 0
sts PORTA_DIR, r16 ;set all pins in portA to input


LOOP: 
;take switch inputs into r16, and store them into our output pins
lds r16, PORTA_IN 
sts PORTC_OUT, r16


rjmp loop

DONE:
rjmp DONE
