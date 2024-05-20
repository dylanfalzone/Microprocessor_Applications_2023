/*
 * lab7_4.c
 *
 * Created: 4/8/2023 1:10:11 PM
 * Purpose: sample cds at 128hz, use interrupts and event system to send 
 *			the data via serial to serialplot
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

			int8_t low = temp & 0xff;
			int8_t high =(temp>>8) & 0xff;
			usartd0_out_char(high);
			usartd0_out_char(low);
			flag = 0;
			sei();
			}
	}
}


void tcc0_init(){
	//( 78*2000000/10000*4)=3900
	TCC0.PER=3900;
	TCC0_CTRLA = TC_CLKSEL_DIV4_gc;
	
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