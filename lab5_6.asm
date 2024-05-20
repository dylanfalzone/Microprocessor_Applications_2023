;******************************************************************************
; File name: lab5_6.asm
; Author: Dylan Falzone
; Last Modified On: 20 March 2023
; Purpose: Using Y index, and USART, receive a string until CR is received.
;		   output that string to the terminal.
;
;******************************************************************************
.include "ATxmega128a1udef.inc"
.equ CR = 0x0D
.equ BS = 0x08
.equ DEL =0x07
.equ Ysize = 9

.dseg
.org 0x2000
STRING:


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
ldi YL, LOW(STRING)
ldi YH, HIGH(STRING)
rcall IN_STRING
ldi YL, LOW(STRING)
ldi YH, HIGH(STRING)
rcall OUT_STRING
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
	TXPOLLING:
	lds r16, USARTD0_STATUS
	sbrs r16, USART_DREIF_bp
	rjmp TXPOLLING

;transmit char
	sts USARTD0_DATA, r17

pop r16
ret

;*********************SUBROUTINE4**********************************
; NAME: OUT_STRING
; Purpose: OUTPUT A STRING to Tx
; INPUT(S): Y register as a pointer to data memory
; OUTPUT(S): N/A
;******************************************************************
OUT_STRING:
push r17
push r18

;r18 is for checking if string is over
ldi r18, 0

OUT_STRING_LOOP:
;store character from string in r17, check if its 0. If it is, leave subroutine.
ld r17, Y+
cp r17, r18
breq DONE_OUT_STRING

;if its not 0, call out_char to output the character and then go back to STRLOOP.
rcall OUT_CHAR
rjmp OUT_STRING_LOOP

DONE_OUT_STRING:

pop r18
pop r17
ret

;*********************SUBROUTINE5**********************************
; NAME: IN_CHAR
; Purpose: INPUT A CHARACTER from Rx
; INPUT(S): N/A
; OUTPUT(S): r17
;******************************************************************
IN_CHAR:
push r16

;check if there is currently an ongoing transmission. If so, poll int flag till done.
	RXPOLLING:
	lds r16, USARTD0_STATUS
	sbrs r16, USART_RXCIF_bp
	rjmp RXPOLLING

;receive char
	lds r17, USARTD0_DATA

pop r16
ret


;*********************SUBROUTINE6**********************************
; NAME: IN_STRING
; Purpose: INPUT A STRING from Rx
; INPUT(S): n/a
; OUTPUT(S): Y pointing to data memory
;******************************************************************
IN_STRING:
push r17
push r18

;take in a character. If its CR, end SR. 
; if it's a backspace or delete, jump to backspacefound
IN_STRING_LOOP:
rcall IN_CHAR
ldi r18, BS
cp r17, r18
breq BACKSPACEFOUND
ldi r18, DEL
cp r17, r18
breq BACKSPACEFOUND
ldi r18, CR
cp r17, r18
breq ENTER

st Y+, r17
rjmp IN_STRING_LOOP

;take in another character. if its a backspace, go to bsfoundagain
;if its not another bs, decrement Y and store it, return to strloop.
BACKSPACEFOUND:
rcall IN_CHAR
ldi r18, BS
cp r17, r18
breq BACKSPACEFOUNDAGAIN
ldi r18, DEL
cp r17, r18
breq BACKSPACEFOUNDAGAIN
st -Y, r17
rjmp IN_STRING_LOOP

;store a 0 in the spot of the first bs. go back to bsfound. 
BACKSPACEFOUNDAGAIN:
ldi r20, 0
st -Y, r20
rjmp BACKSPACEFOUND

;enter found, store a zero and leave sr. 
ENTER:
ldi r17, 0
st Y+, r17


pop r18
pop r17
ret