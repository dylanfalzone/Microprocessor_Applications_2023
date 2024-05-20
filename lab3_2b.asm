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

.equ F = 2000000
.equ PRE = 1
.equ PD = 5
.equ PDDIV = 1000

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

;set interrupt sense config to falling edge 
ldi r16, 0b00000010
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

;*********************SUBROUTINE3**********************************
; NAME: TC_INIT
; Purpose: start the clock (used for debouncing)
; INPUT(S): N/A
; OUTPUT(S): N/A
;
;******************************************************************
TC_INIT:
push r20

ldi r20, low((F*PD)/(PDDIV*PRE)) ; 
sts TCC0_PER, r20
ldi r20, high((F*PD)/(PDDIV*PRE))
sts (TCC0_PER+1), r20

ldi r20, TC_CLKSEL_DIV1_gc ; start the clock!
sts TCC0_CTRLA, r20

pop r20
ret


;*********************SUBROUTINE4**********************************
; NAME: DEBOUNCER
; Purpose: wait 10ms, then return to program
; INPUT(S): N/A
; OUTPUT(S): N/A
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
	sbrs r19, 0 ;skip next instruction if intflag is set
	rjmp DLOOPDELAY ;intflag isnt set so we keep looping

	;reset the overflow
	ldi r19, TC0_OVFIF_bm ;load r19 with the bm to reset overflow
	sts TCC0_INTFLAGS, r19 ;reset overflow

	;run the 5ms delay 2x for 10ms debounce time
	inc r21
	cpi r21, 2
	brne DLOOPDELAY

;return to program
pop r21
pop r19
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
push r20
push r17

rcall DEBOUNCER
lds r20, PORTF_IN
sbrc r20, 2
rjmp ISR1DONE

inc r18
com r18
sts PORTC_OUT, r18
com r18


ISR1DONE:


pop r17
pop r20
pop r16
sts CPU_SREG, r16
pop r16
reti