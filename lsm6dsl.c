/*
 * lsm6dsl.c
 *
 * Created: 3/24/2023 7:31 PM
 * Author: Dylan Falzone
 * Purpose: functions for writing and reading to/from the IMU. 
 */ 

#include <avr/io.h>
#include "lsm6dsl.h"
#include "lsm6dsl_registers.h"


void LSM_write(uint8_t reg_addr, uint8_t data)
{
	uint8_t addr = 0b01111111 & reg_addr;//first bit to 0 for write
	PORTF.OUTTGL = 0b00010000; //toggle cs
	spi_write(addr); //transmit addr
	spi_write(data); //transmit data
	PORTF.OUTTGL = 0b00010000; //toggle cs
}
uint8_t LSM_read(uint8_t reg_addr)
{
	uint8_t addr = 0b10000000 | reg_addr; //first bit to 1 for read
	PORTF.OUTTGL = 0b00010000; //toggle cs
	spi_write(addr); //transmit addr
	uint8_t data=spi_read(); //read data
	PORTF.OUTTGL = 0b00010000; //toggle cs
	return data;//return data
}