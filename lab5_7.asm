;******************************************************************************
; File name: lab5_7.asm
; Author: Dylan Falzone
; Last Modified On: 20 March 2023
; Purpose: toggle blue LED in main, when a transmission is received,
;		   use the interrupt to report it back to the terminal and return
;		   to position in main. 
;
;******************************************************************************
.include "ATxmega128a1udef.inc"

.cseg
.org 0x00
rjmp MAIN

;place rjmp to ISR at the USARTD0_RXC intvector
.org USARTD0_RXC_vect
rjmp ISR1


.org 0xFE
MAIN:
 ;init stack
ldi r16, ((0x3fff>>0) & 0xff)
sts CPU_SPL, r16
ldi r16, ((0x3fff>>8) & 0xff)
sts CPU_SPH, r16

;init IO, INTERRUPT
rcall IO_INIT
rcall INT_INIT

;init USART pins
rcall USARTPINS_INIT
;init USART
rcall USART_INIT

ldi r18, 0x00 ;this will hold our incremented value for the LEDs

	LOOP:
	sei ;global interrupt somehow is getting turned off somewhere so I need this in the loop.
	ldi r17, 0b01000000
	sts PORTD_OUTTGL, r17 ;toggle blue LED
	rjmp LOOP

;*********************SUBROUTINE1**********************************
; NAME: USARTPINS_INIT
; Purpose: INITIALIZE USART PINS
; INPUT(S): N/A
; OUTPUT(S): N/A
;******************************************************************
USARTPINS_INIT:
push r16

.equ BIT3 = 1<<3 ; TX is pin3
.equ BIT2 = 1<<2 ; RX is pin2

;set PORTD_PIN3 to output, output a 1 (idle) (TX)
	ldi r16, BIT3
	sts PORTD_OUTSET, r16
	sts PORTD_DIRSET, r16

;set portd_pin2 to input (RX)
	ldi r16, BIT2
	sts PORTD_DIRCLR, r16

pop r16
ret

;*********************SUBROUTINE2**********************************
; NAME: USART_INIT
; Purpose: INITIALIZE USART
; INPUT(S): N/A
; OUTPUT(S): N/A
;******************************************************************
USART_INIT:
push r16

.equ BSCALE= -6
.equ BSEL= 63

;Set config USART module by setting parity, cmode, size, and sb(auto)
	ldi r16, (USART_PMODE_ODD_gc | \
				USART_CMODE_ASYNCHRONOUS_gc | \
				USART_CHSIZE_8BIT_gc)
	sts USARTD0_CTRLC, r16

;Set data direction of USART transmit pin (rx, tx)
	ldi r16, (1<<4 | 1<<3)
	sts USARTD0_CTRLB, r16

;Set baud rate
	;set baudctrla to lower 8bits of bsel 
	ldi r16, low(BSEL)
	sts USARTD0_BAUDCTRLA, r16

	;set baudctrlb to bscale | bsel
	ldi r16, ((BSCALE <<4) | high(BSEL))
	sts USARTD0_BAUDCTRLB, r16

pop r16
ret



;*********************SUBROUTINE3**********************************
; NAME: IO_INIT
; Purpose: INITIALIZE NECESSARY IO PORT
; INPUT(S): N/A
; OUTPUT(S): N/A
;******************************************************************
IO_INIT:
push r16

;init portD (RGB)
ldi r16, 0xff
sts PORTD_OUTSET, r16 ;turn off all leds
ldi r16, 0b01000000
sts PORTD_DIRSET, r16 ;set all pins in portD to Output
pop r16
ret


;*********************SUBROUTINE4**********************************
; NAME: INT_INIT
; Purpose: INITIALIZE INTERRUPT
; INPUT(S): N/A
; OUTPUT(S): N/A
;******************************************************************
INT_INIT:
push r16

;choose high level interrupt
ldi r16, 0b00110000
sts USARTD0_CTRLA, r16

;enable high level interrupts globally
ldi r16, 0x04
sts PMIC_CTRL, r16

;enable interrupts globally
sei

pop r16
ret




;***********ISR1****************
; Name: ISR1
; Purpose: when received, transmit
; Inputs: N/A
; Outputs: N/A
;********************************
ISR1:
push r16
ldi r16, CPU_SREG
push r16
push r17

;receive char
	lds r17, USARTD0_DATA

;transmit char
	TXPOLLING:
	lds r16, USARTD0_STATUS
	sbrs r16, USART_DREIF_bp
	rjmp TXPOLLING

;transmit char
	sts USARTD0_DATA, r17

pop r17
pop r16
sts CPU_SREG, r16
pop r16
reti