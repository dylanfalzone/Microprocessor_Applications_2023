/*
 * spi.c
 *
 * Created: 3/24/2023
 * Author: Dylan Falzone
 * Purpose: define functions for initializing, reading and writing to SPI
 * Functions: SPI_INIT(VOID), SPI_WRITE(UINT8_T, DATA), SPI_READ(VOID)
 */ 
#include <avr/io.h>
#include "spi.h"


void spi_init(void)
{
	
	//set SCK, MOSI, CS to output a 1 for idle	
	PORTF.OUTSET = 0b10110000;
	PORTF.DIRSET = 0b10110000;
	PORTF.DIRCLR = 0b01001111;
	
	//set controls for mode 0, master, enable on
	SPIF.CTRL	=SPI_PRESCALER_DIV128_gc		    |
	SPI_CLK2X_bm      |
	SPI_MASTER_bm	  |
	SPI_MODE_0_gc         |
	SPI_ENABLE_bm;

}

void spi_write(uint8_t data)
{	
	SPIF.DATA = data; //transmit data
	while(!(SPIF.STATUS & SPI_IF_bm)){ //poll till transmission complete
	}
}

uint8_t spi_read(void)
{
	SPIF.DATA = 0x80; //transmit garbage data
	while(!(SPIF.STATUS & SPI_IF_bm)){ //poll until complete
	}
	return SPIF.DATA; //return received data
}

