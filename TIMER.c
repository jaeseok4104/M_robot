#include <mega128.h>
#include <stdio.h>
#include <delay.h>
#include <math.h>

#include "TIMER.h"
#include "RTU_USART.h"

interrupt [TIM2_COMP] void timer2_comp(void)
{
    TIMER2_OVERFLOW++;
}

interrupt [TIM0_OVF] void timer0_ovf(void)
{
    TIMER0_OVERFLOW++;
}


interrupt [TIM1_COMPB] void timer0_comp(void)
{
    TIMER1_OVERFLOW++;
    TCNT1H = 0x00;
    TCNT1L = 0x00;
}

void timer2_init(void)
{
    //TIMER2
    TCCR2 = (1<<WGM21)|(1<<CS22)|(1<<CS20);// CTC모드, 1024분주

    OCR2 = 40;
    TIMSK = (1<<OCIE2)|(1<<OCIE0); 
    //TIMSK = (1<<OCIE2);
}
void timer0_init(void)
{
    TCCR0 = (1<<CS02)|(1<<CS01)|(1<<CS00); // CTC모드, 1024분주
    TIMSK = (1<<OCIE2)|(1<<TOIE0);
}

void timer1_init(void)
{
    // TCCR1A = (1<<COM1B0);
    TCCR1B = (1<<WGM13)|(1<<WGM12)|(1<<CS12)|(1<<CS10);; // WGM bit setting

    OCR1B = 255;
    ICR1 = 1200;
    TIMSK |= (1<<OCIE1B);
}