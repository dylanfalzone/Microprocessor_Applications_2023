/*
 * lab7_2.c
 *
 * Created: 4/8/2023 1:10:11 PM
 * Purpose: use events and interrupts to sample and toggle an led at 6hz
 *  Author: dylan
 */ 

#include <avr/io.h>
#include <avr/interrupt.h>
volatile int16_t temp;
void tcc0_init();
void adc_init();


int main(void)
{
	//initialize LED
	PORTD.OUTSET=0b00010000;
	PORTD.DIRSET=0b00010000;
	
	//call functions
	adc_init();
	tcc0_init();
	while(1){
	
	//sei of course
	sei();
	}
}


void tcc0_init(){
	//( (1/6)*2000000)/256 = 1302
	TCC0.PER=1302;
	TCC0_CTRLA = TC_CLKSEL_DIV256_gc;
	
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
	PORTD.OUTTGL = 0b00010000;
}