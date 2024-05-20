/*
 * lab6_5.c
 *
 * Created: 3/31/2023 10:17:03 AM
 *  Author: use accelerometer on IMU to output to serial monitor whenever
 *		    an interrupt is detected from the IMU. 
 */ 
#include <avr/io.h>
#include "spi.h"
#include "lsm6dsl_registers.h"
#include "lsm6dsl.h"
#include <avr/interrupt.h>
void LSM_init();
volatile uint8_t accel_flag = 0;

int main(){
	spi_init(); //init spi
		//init pc6 as input
		PORTC_DIRCLR = 0b01000000;
		//configure int1 as the portc interrupt on the xmega (pc6)
		PORTC_INTCTRL = 0x03; //high level
		PORTC_PIN6CTRL = 0b00000011; //rising edge sensing
		PORTC_INT0MASK = 0b01000000; //pin6
		PMIC_CTRL = 0x04; //enable high lvl
		sei(); //global interrupt enable
	LSM_init(); //init accel
	usartd0_init();//init usart
	


	while(1){
			if(accel_flag == 1){
				cli();

				
				uint8_t addr = OUTX_H_XL;
				int8_t x= LSM_read(addr); //x high byte
				usartd0_out_char(x);
				addr =OUTX_L_XL;
				x = LSM_read(addr); //x low byte
				usartd0_out_char(x);

				addr = OUTY_H_XL;
				int8_t y= LSM_read(addr); //y high byte
				usartd0_out_char(y);
				addr = OUTY_L_XL;
				y = LSM_read(addr); //y low byte
				usartd0_out_char(y);

				addr = OUTZ_H_XL;
				int8_t z= LSM_read(addr); //z high byte
				usartd0_out_char(z);
				addr = OUTZ_L_XL; //z low byte
				z=LSM_read(addr);
				usartd0_out_char(z);
				
				accel_flag = 0;
				
				sei();
			}
	}
}

void LSM_init(){


	//write 1 to ctrl3_c for software reset
	uint8_t addr = CTRL3_C;
	uint8_t data = 0b00000001;
	LSM_write(addr,data);
	
	//configure ctrl9_xl for everything enabled
	addr = CTRL9_XL;
	data = 0b1111100;
	LSM_write(addr, data);
	
	
	//configure ctrl1_xl for normal mode, +-2g
	addr = CTRL1_XL;
	data = 0b01010100;
	LSM_write(addr, data);
	
	//configure int1_ctrl for accel data ready
	addr = INT1_CTRL;
	data = 0b00000001;
	LSM_write(addr, data);
	

}

ISR(PORTC_INT0_vect)
{
accel_flag = 1;
}
