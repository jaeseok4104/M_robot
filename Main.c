#include <mega128.h>
#include <stdio.h>
#include <delay.h>

#define bps_115200 0x0007

#define POLYNORMIAL 0xA001

#define CHARACTER3_5 25

#define R 0x01
#define L 0x02

unsigned char TIMER2_OVERFLOW = 0;
unsigned char PACKET_BUFF[100] = {0,};
unsigned char PACKET_BUFF_IDX = 0;

unsigned char TIMER0_OVERFLOW = 0;
unsigned char VELOCITY_BUFF[20] = {0,};
unsigned char VELOCITY_BUFF_IDX = 0;
unsigned char CHECK_GETS = 0;

void usart1_init(int bps)
{
    UCSR1A = 0x00;
    UCSR1B = (1<<RXEN1)|(1<<TXEN1)|(1<<RXCIE1); // RXCIE1 bit is recevie interrupt allow 
    UCSR1C = (1<<UCSZ11)|(1<<UCSZ10);
    UCSR1C &= ~(1<<UMSEL1);

    UBRR1H = (unsigned char)((bps>>8)  & 0x00ff);
    UBRR1L = (unsigned char)(bps & 0x00ff);
}

void usart0_init(int bps)
{
    UCSR0A = 0x00;
    UCSR0B = (1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0); // RXCIE1 bit is recevie interrupt allow 
    UCSR0C = (1<<UCSZ01)|(1<<UCSZ00);
    UCSR0C &= ~(1<<UMSEL0);

    UBRR0H = (unsigned char)((bps>>8)  & 0x00ff);
    UBRR0L = (unsigned char)(bps & 0x00ff);
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
    TCCR0 = (1<<WGM01)|(1<<CS02)|(1<<CS01)|(1<<CS00); // CTC모드, 1024분주
    OCR0 = 40;
    TIMSK = (1<<OCIE2)|(1<<OCIE0);
}

void putch_USART1(char data)
{
    while(!(UCSR1A & (1<<UDRE1))); // UDRE flag is USART Data Register Empty
    UDR1 = data;
}

//USART 문자열 송신
void puts_USART1(char *str,char IDX)
{
    unsigned char i = 0;

    for(i = 0;i<IDX;i++)
    {
        putch_USART1(*(str+i));
    }

    for(i = 0; i<IDX; i++)
    {
        *(str+i) = 0;
    }
}

void puts_Modbus1(char *str,char IDX)
{
    unsigned char i = 0;
    UCSR0B &= ~(1<<RXEN0);
    if(TIMER2_OVERFLOW>0)
    {       
        for(i = 0;i<IDX-1;i++) putch_USART1(*(str+i));

        for(i = 0; i<IDX; i++) *(str+i) = 0;
    }
    UCSR0B |= (1<<RXEN0);
}

void putch_USART0(char data)
{
    while(!(UCSR0A & (1<<UDRE0))); // UDRE flag is USART Data Register Empty
    UDR0 = data;
}

void puts_USART0(char *str,char IDX)
{
    //PACKET_BUFF[PACKET_BUFF_IDX] = 0;
    unsigned char i = 0;
    for(i = 0;i<IDX-1;i++)
    {
        putch_USART1(*(str+i));
    }

    for(i = 0; i<IDX; i++)
    {
        *(str+i) = 0;
    }
}

unsigned short CRC16(unsigned char *puchMsg, int usDataLen)
{
    int i;
    unsigned short crc, flag;
    crc = 0xffff; 
    
    while(usDataLen--){
        crc ^= *puchMsg++; 
        
        for (i=0; i<8; i++){
            flag = crc & 0x0001;
            crc >>= 1;
            if(flag) crc ^= POLYNORMIAL;
        }
    }
    return crc;
}

int RTU_WriteOperate0(char device_address,int starting_address,int data)
{
    char protocol[8];
    unsigned short crc16;
    int i=0;
    //PACKET_BUFF_IDX = 0;

    protocol[0]=device_address;
    protocol[1]=0x06;
    protocol[2]=((starting_address>>8)  & 0x00ff);
    protocol[3]=((starting_address)     & 0x00ff);
    protocol[4]=((data>>8)              & 0x00ff);
    protocol[5]=((data)                 & 0x00ff);
    protocol[6]=0;
    protocol[7]=0;
    
    crc16 = CRC16(protocol, 6);
    
    protocol[6] = (unsigned char)((crc16>>0) & 0x00ff);
    protocol[7] = (unsigned char)((crc16>>8) & 0x00ff);
               
    
    for(i=0;i<8;i++)
    {
        putch_USART0(*(protocol+i));
    }
}

int RTU_WriteOperate1(char device_address,int starting_address,int data)
{
    char protocol[8];
    unsigned short crc16;
    int i=0;
   // PACKET_BUFF_IDX = 0;

    protocol[0]=device_address;
    protocol[1]=0x06;
    protocol[2]=((starting_address>>8)  & 0x00ff);
    protocol[3]=((starting_address)     & 0x00ff);
    protocol[4]=((data>>8)              & 0x00ff);
    protocol[5]=((data)                 & 0x00ff);
    protocol[6]=0;
    protocol[7]=0;
    
    crc16 = CRC16(protocol, 6);
    
    protocol[6] = (unsigned char)((crc16>>0) & 0x00ff);
    protocol[7] = (unsigned char)((crc16>>8) & 0x00ff);
               
    
    for(i=0;i<8;i++)
    {
        putch_USART1(*(protocol+i));
    }
}

int RTU_ReedOperate0(char device_address,int starting_address,int data)
{
    char protocol[8];
    unsigned short crc16;
    int i=0;
    //PACKET_BUFF_IDX = 0;

    protocol[0]=device_address;
    protocol[1]=0x03;
    protocol[2]=((starting_address>>8)  & 0x00ff);
    protocol[3]=((starting_address)     & 0x00ff);
    protocol[4]=((data>>8)              & 0x00ff);
    protocol[5]=((data)                 & 0x00ff);
    protocol[6]=0;
    protocol[7]=0;
    
    crc16 = CRC16(protocol, 6);
    
    protocol[6] = (unsigned char)((crc16>>0) & 0x00ff);
    protocol[7] = (unsigned char)((crc16>>8) & 0x00ff);
               
    
    for(i=0;i<8;i++)
    {
        putch_USART0(*(protocol+i));
    }
}

// interrupt [USART0_RXC] void usart0_rxc(void)
// {
//     unsigned char i = 0;

//     i = UDR0;
//     if(i == '<'){
//         PACKET_BUFF_IDX = 0;
//         PACKET_BUFF[PACKET_BUFF_IDX] = i;
//         PACKET_BUFF_IDX++;
//     }
//     else if(i == '>'){
//         PACKET_BUFF[PACKET_BUFF_IDX] = i;
//         PACKET_BUFF_IDX+=2;
//     }
//     else{
//         PACKET_BUFF[PACKET_BUFF_IDX] = i;
//         PACKET_BUFF_IDX++;
//     }
// }

interrupt [USART0_RXC] void usart0_rxc(void)
{
    if(((TCNT2 < CHARACTER3_5) && (TIMER2_OVERFLOW == 0)) || PACKET_BUFF_IDX == 0)
    {
        PACKET_BUFF[PACKET_BUFF_IDX] = UDR0;
        PACKET_BUFF_IDX++;
        TCNT2 = 0;
    }
    else {
        PACKET_BUFF_IDX = 0;
        PACKET_BUFF[PACKET_BUFF_IDX] = UDR0;
        PACKET_BUFF_IDX++;
        TCNT2 = 0;
        TIMER2_OVERFLOW = 0;
    }
}

interrupt [USART1_RXC] void usart1_rxc(void)
{
    unsigned char i = 0;
    i = UDR1;
    if(i == '<'){
        VELOCITY_BUFF_IDX = 0;
        VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
        VELOCITY_BUFF_IDX++;
        CHECK_GETS = 1;
    }
    else if(i == '>'){
        VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
        VELOCITY_BUFF_IDX++;
        CHECK_GETS = 0;
    }
    else{
        VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
        VELOCITY_BUFF_IDX++;
    }
}

// interrupt [USART1_RXC] void usart1_rxc(void)
// {
//     if(((TCNT0 < CHARACTER3_5) && (TIMER2_OVERFLOW == 0)) || VELOCITY_BUFF_IDX == 0)
//     {
//         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = UDR1;
//         TCNT0 = 0;
//         //PORTB.1 = ~PORTB.1;
//     }
//     else {
//         VELOCITY_BUFF_IDX = 0;
//         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = UDR0;
//         VELOCITY_BUFF_IDX++;
//         TCNT0 = 0;
//         //PORTB.1 = ~PORTB.1;
//         TIMER2_OVERFLOW = 0;

//     }
// }

// interrupt [USART1_RXC] void usart1_rxc(void)
// {
//     if(((TCNT0 < CHARACTER3_5) && (TIMER2_OVERFLOW == 0)) || VELOCITY_BUFF_IDX == 0)
//     {
//         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = UDR1;
//         TCNT0 = 0;
//         //PORTB.1 = ~PORTB.1;
//     }
//     else {
//         VELOCITY_BUFF_IDX = 0;
//         VELOCITY_BUFF[VELOCITY_BUFF_IDX] = UDR0;
//         VELOCITY_BUFF_IDX++;
//         TCNT0 = 0;
//         //PORTB.1 = ~PORTB.1;
//     }
// }

interrupt [TIM2_COMP] void timer2_comp(void)
{
    TIMER2_OVERFLOW++;
}

interrupt [TIM0_COMP] void timer0_comp(void)
{
    TIMER0_OVERFLOW++;
}

void main(void)
{
    int velocity_R = 0;
    int velocity_L = 0;
    unsigned char BUFF[100] = {0,};

    usart1_init(bps_115200);
    usart0_init(bps_115200);
    timer2_init();
    SREG |= 0x80;
    DDRB.1 = 1;
    PORTB.1 = 0;
    delay_ms(5000);
    while(1)
    {
        if(CHECK_GETS == 0)
        {
            UCSR1B &= ~(1<<RXEN1);
            sscanf(VELOCITY_BUFF,"<%d,%d>", &velocity_R, &velocity_L);
            sprintf(BUFF,"<%d,%d>", velocity_R, velocity_L);

            //puts_USART1(BUFF,VELOCITY_BUFF_IDX);

            UCSR1B |=(1<<RXEN1);
            RTU_WriteOperate0(R,(unsigned int)121,(int)(velocity_R));
            delay_ms(5);

            RTU_WriteOperate0(L,(unsigned int)121,(int)-(velocity_L));
            delay_ms(5);

            RTU_WriteOperate0(R,(unsigned int)120,(int)(1));
            delay_ms(5);

            RTU_WriteOperate0(L,(unsigned int)120,(int)(1));
            delay_ms(5);
        } 
    }
}