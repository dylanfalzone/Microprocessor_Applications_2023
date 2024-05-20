/*
 * lab6_3.c
 *
 * Created: 3/24/2023 7:30:09 PM
 * Author: Dylan Falzone
 * Purpose: use SPI to read from "who am I" register on the IMU
 */ 
#include <avr/io.h>
#include "spi.h"
#include "lsm6dsl_registers.h"


int main(){
	spi_init(); //init spi
	while(1){
		uint8_t reg_addr = WHO_AM_I; //addr of who am i register
		uint8_t data = LSM_read(reg_addr); //call read for that register
		uint8_t dummy = 0x80; //dummy instruction so we can see received data
	}
}