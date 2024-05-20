/*
 * lab8_1.c
 *
 * Created: 4/17/2023 6:33:37 PM
 * Author : dylan
 */ 

#include <avr/io.h>
extern void clock_init(void);

int main(void)
{
   //Just ch0
   DACA.CTRLB = DAC_CHSEL_SINGLE_gc;
   
   //arefb 2.5v
   DACA.CTRLC = DAC_REFSEL_AREFB_gc;
   
   //CH0 AND ENABLE
   DACA.CTRLA=DAC_CH0EN_bm | DAC_ENABLE_bm;
   
    while (1) 
    {
		while(!(DACA.STATUS & DAC_CH0DRE_bm));
		//close enough to 2v
		DACA.CH0DATA = 0XCDE;
    }
}

