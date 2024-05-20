/*
 * lab7_3.c
 *
 * Created: 4/8/2023 1:10:11 PM
 * Purpose: sample cds at 1hz, use interrupts and event system to send 
 *			the data via serial to putty
 *  Author: dylan
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
volatile uint8_t flag=0;
volatile int16_t temp;
volatile uint16_t temp2;
volatile uint16_t rectified;
void tcc0_init();
void adc_init();


int main(void)
{
	//initialize LED
	PORTD.OUTSET=0b00010000;
	PORTD.DIRSET=0b00010000;
	
	//init adc, tcc0, usartd0
	adc_init();
	tcc0_init();
	usartd0_init();
	sei();
	while(1){
		if(flag == 1){
			cli();
			uint8_t sign;
			if(temp & 0b1111100000000000){
				sign = 0x2d;
			}
			else{
				sign = 0x2b;
			}
			usartd0_out_char(sign);
			rectified=abs(temp);
			float voltage = (rectified);
			voltage = voltage/2048*2.5;
			
			uint8_t int1 = (int)voltage;
			usartd0_out_char(int1+48);
			usartd0_out_char(0x2e); //.
			float v2 = 10*(voltage-int1);
			uint8_t int2 = (int)v2;
			usartd0_out_char(int2+48);
			float v3 = 10*(v2-int2);
			uint8_t int3 = (int)v3;
			usartd0_out_char(int3+48);
			usartd0_out_char(0x20); //space
			usartd0_out_char(0x56); //V
			
			usartd0_out_char(0x20); //space
			usartd0_out_char(0x28); //open parenth
			
	
			uint8_t temp3 = (rectified & 0xF);
			  rectified >>= 4;
			uint8_t  temp4 = (rectified & 0xF);
			  rectified >>= 4;
			uint8_t  temp5 = (rectified & 0xF);
			  
			 uint8_t output1 = (temp3 > 9) ? 'A' + temp3 - 10 : '0' + temp3;
			 uint8_t output2 = (temp4 > 9) ? 'A' + temp4 - 10 : '0' + temp4;
			 uint8_t output3 = (temp5 > 9) ? 'A' + temp5 - 10 : '0' + temp5;
			 
			usartd0_out_char(48);//0
			usartd0_out_char(88);//x
			usartd0_out_char(output1);
			usartd0_out_char(output2);
			usartd0_out_char(output3);
			usartd0_out_char(0x29); //close parenth
			usartd0_out_char(13); //CR
			usartd0_out_char(10); //LF

			flag = 0;
			sei();
			}
	}
}


void tcc0_init(){
	//( 2000000/1024=1953
	TCC0.PER=1953;
	TCC0_CTRLA = TC_CLKSEL_DIV1024_gc;
	
	EVSYS.CH0MUX = EVSYS_CHMUX_TCC0_OVF_gc;
}

void adc_init(){
	
	//signed, 12 bit right adjusted
	ADCA.CTRLB = ADC_CONMODE_bm | ADC_RESOLUTION_12BIT_gc;
	
	//external 2.5v
	ADCA.REFCTRL = ADC_REFSEL_AREFB_gc;
	
	//speed
	ADCA.PRESCALER=ADC_PRESCALER_DIV4_gc;
	
	//differential mode
	ADCA.CH0.CTRL = ADC_CH_INPUTMODE_DIFF_gc;
	
	//select PA1, PA6 from muxctrl (cds+, cds-)
	ADCA.CH0.MUXCTRL = ADC_CH_MUXPOS_PIN1_gc | ADC_CH_MUXNEG_PIN6_gc;

	//adc interrupt when conv is complete
	ADCA.CH0.INTCTRL = 3; //high level. mode is automatic, 00=complete.
	
	//adc conv start when EVC0 is triggered
	ADCA.EVCTRL = 0b00000001; //channel o, event channel 0, channel 0 trigger

	//enable ADC
	ADCA.CTRLA = ADC_ENABLE_bm;
	
	//enable interrupts
	PMIC_CTRL = 4;
	
}

ISR(ADCA_CH0_vect ){
	//load sample and toggle LED
	temp=ADCA.CH0.RES;
	flag=1;
	PORTD.OUTTGL = 0b00010000;
}