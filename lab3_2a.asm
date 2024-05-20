;******************************************************************************
; File name: lab3_2a.asm
; Author: Dylan Falzone
; Last Modified On: 17 Feb 2023
; Purpose: Trigger interrupt on S1 SLB press. Count how many
;			interrupts occur and display that on the leds in binary.
;			also continually toggle the green LED in main loop.
;
;******************************************************************************
.include "ATxmega128a1udef.inc"

.cseg
.org 0x00
rjmp MAIN

;place rjmp to ISR at the PORTF INT0 intvector
.org PORTF_INT0_vect
rjmp ISR1


.org 0xFD
MAIN:
 ;init stack
ldi r16, ((0x3fff>>0) & 0xff)
sts CPU_SPL, r16
ldi r16, ((0x3fff>>8) & 0xff)
sts CPU_SPH, r16

;init IO, INTERRUPT
rcall IO_INIT
rcall INT_INIT
ldi r18, 0x00 ;this will hold our incremented value for the LEDs

	LOOP:
	sei ;global interrupt somehow is getting turned off somewhere so I need this in the loop.
	ldi r17, 0b00100000
	sts PORTD_OUTTGL, r17 ;toggle green LED
	rjmp LOOP


;*********************SUBROUTINE1**********************************
; NAME: IO_INIT
; Purpose: INITIALIZE NECESSARY IO PORT
; INPUT(S): N/A
; OUTPUT(S): N/A
;******************************************************************
IO_INIT:
push r16

;init portc (LEDs)
ldi r16, 0xff
sts PORTC_OUT, r16 ;set all outputs to 1 (leds off)
sts PORTC_DIR, r16 ;set all pins in portc to output

;init portF (s1,s2 SLB)
ldi r16, 0 
sts PORTF_DIR, r16 ;set all pins in portF to input

;init portD (RGB)
ldi r16, 0xff
sts PORTD_OUT, r16 ;turn off all leds
sts PORTD_DIR, r16 ;set all pins in portD to Output
pop r16
ret


;*********************SUBROUTINE2**********************************
; NAME: INT_INIT
; Purpose: INITIALIZE INTERRUPT
; INPUT(S): N/A
; OUTPUT(S): N/A
;******************************************************************
INT_INIT:
push r16

;choose high level interrupt
ldi r16, 0x03
sts PORTF_INTCTRL, r16

;set interrupt sense config to level 
ldi r16, 0b00000011
sts PORTF_PIN2CTRL, r16

;choose pin2 (s1) as the interrupt 0 for port f
ldi r16, 0b00000100
sts PORTF_INT0MASK, r16

;enable high level interrupts globally
ldi r16, 0x04
sts PMIC_CTRL, r16

;enable interrupts globally
sei

pop r16
ret




;***********ISR1****************
; Name: ISR1
; Purpose: increment r18, set LEDs
; Inputs: N/A
; Outputs: N/A
;********************************
ISR1:
push r16
ldi r16, CPU_SREG
push r16
push r17

inc r18
com r18
sts PORTC_OUT, r18
com r18

;ldi r17, 1
;sts PORTF_INTFLAGS, r17

pop r17
pop r16
sts CPU_SREG, r16
pop r16
reti