/*
 * clock_test.c
 *
 * Created: 4/12/2023 1:41:49 PM
 * Author : dylan
 */ 

#include <avr/io.h>

extern void clock_init(void);
extern

int main(void)
{
	clock_init();
	PORTCFG.CLKEVOUT = PORTCFG_CLKOUT_PC7_gc;
	PORTC.DIRSET = 0b10000000;
    while (1){};
}

