/*
 * lab7_1.c
 *
 * Created: 4/8/2023 10:39:01 AM
 * Purpose: Initialize and run ADCA ch0 for the analog backpack's cds. 
 * Author : dylan
 */ 

#include <avr/io.h>

void adc_init();


int main(void)
{
    while (1) 
    {
		adc_init();
		int16_t temp;
		
		//start adc
		ADCA.CH0.CTRL |= ADC_CH_START_bm;
		
		//wait for adc to be completed
		while(!(ADCA.CH0.INTFLAGS & ADC_CH_CHIF_bm));
		
		//clear interrupt flag
		ADCA.CH0.INTFLAGS = ADC_CH_CHIF_bm; 
		
		//load result
		temp = ADCA.CH0.RES; 
		
		//dummy instruction for reading
			asm("nop");
    }
}

//init ADCA module
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

	//enable ADC
	ADCA.CTRLA = ADC_ENABLE_bm;
}