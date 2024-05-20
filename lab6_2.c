/*
 * lab6_2.c
 *
 * Created: 3/24/2023 7:30:09 PM
 * Author: Dylan Falzone
 * Purpose: transmit a hex19 repeatedly through SPI
 */ 
#include <avr/io.h>
#include "spi.h"



int main(){
	spi_init(); //init spi
	while(1){ //inf loop
	uint8_t data = 0x19; //set data to 0x19
	PORTF.OUTTGL = 0b00010000; //toggle cs
	spi_write(data); //transmit data
	PORTF.OUTTGL = 0b00010000; //toggle cs
		
	}
}