;******************************************************************************
; File name: lab4_2.asm
; Author: Dylan Falzone
; Last Modified On: 4 MAR 2023
; Purpose: 
;
;******************************************************************************
.include "ATxmega128a1udef.inc"

;symbols for start of relevant memory address ranges
.equ SRAM_START_ADDR = 0x560000
.equ IO_START_ADDR = 0x336000



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

;init EBI
rcall EBI_INIT

ldi YL, byte1(IO_START_ADDR)
ldi YH, byte2(IO_START_ADDR)
ldi r16, byte3(IO_START_ADDR)
sts CPU_RAMPY, r16

	LOOP:

	ld r16, Y
	st Y, r16

	rjmp LOOP


;*********************SUBROUTINE1**********************************
; NAME: EBI_INIT
; Purpose: initialize EBI
; INPUT(S): N/A
; OUTPUT(S): N/A
;
;******************************************************************
EBI_INIT:
push r16

;Initialize the relevant EBI control signals to be in a false state
ldi r16, 0b01010011
sts PORTH_OUTSET, r16
ldi r16, 0b00000100
sts PORTH_OUTCLR, r16

;init the EBI control signals to be output from the micro controller
ldi r16, 0b01010111 ;(WE_bm or RE_bm or ALE1_bm or CS0bm or CS2bm)
sts PORTH_DIRSET, r16

;initialize the address signals to be output from microcontroller
ldi r16, 0XFF
sts PORTK_DIRSET, r16

;init EBI for sram 3 port ale1
ldi r16, 0b00000001
sts EBI_CTRL, r16

;init CS0
ldi r16, 0b00011101
sts EBI_CS0_CTRLA, r16
ldi r16, byte2(SRAM_START_ADDR)
sts EBI_CS0_BASEADDR, r16
ldi r16, byte3(SRAM_START_ADDR)
sts EBI_CS0_BASEADDR+1, r16

;init CS2
ldi r16, 0b00000001
sts EBI_CS2_CTRLA, r16
ldi r16, byte2(IO_START_ADDR)
sts EBI_CS2_BASEADDR, r16
ldi r16, byte3(IO_START_ADDR)
sts EBI_CS2_BASEADDR+1, r16

pop r16
ret

