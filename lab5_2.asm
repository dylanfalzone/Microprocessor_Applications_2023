;******************************************************************************
; File name: lab5_2.asm
; Author: Dylan Falzone
; Last Modified On: 17 March 2023
; Purpose: Use USART to transmit an ASCII character to terminal with
;			8 data bits, 1 start, 1 stop, and odd parity at 63k baud rate
;
;******************************************************************************
.include "ATxmega128a1udef.inc"


.cseg
.org 0x00
rjmp MAIN


.org 0xFE
MAIN:
;init stack
ldi r16, ((0x3fff>>0) & 0xff)
sts CPU_SPL, r16
ldi r16, ((0x3fff>>8) & 0xff)
sts CPU_SPH, r16

;init USART pins
rcall USARTPINS_INIT
;init USART
rcall USART_INIT

LOOP:

;load r17 with the value that corresponds to 'U'
ldi r17, 0x55
;output the value to tx
rcall OUT_CHAR
rjmp LOOP

DONE:
rjmp DONE


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
; NAME: OUT_CHAR
; Purpose: OUTPUT A CHARACTER to Tx
; INPUT(S): r17
; OUTPUT(S): N/A
;******************************************************************
OUT_CHAR:
push r16

;check if there is currently an ongoing transmission. If so, poll int flag till done.
	POLLING:
	lds r16, USARTD0_STATUS
	sbrs r16, USART_DREIF_bp
	rjmp POLLING

;transmit char
	sts USARTD0_DATA, r17

pop r16
ret