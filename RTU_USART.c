#include <mega128.h>
#include <stdio.h>
#include <delay.h>
#include <math.h>

#include "TIMER.h"
#include "RTU_USART.h"

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
    if((i == '<') && (CHECK_GETS == 0)){
        PORTB.3 = ~PORTB.3;
        VELOCITY_BUFF_IDX = 0;
        VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
        VELOCITY_BUFF_IDX++;
    }
    else if(i == '>' && (CHECK_GETS == 0)){
        VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
        VELOCITY_BUFF_IDX++;
        CHECK_GETS = 1;
    }
    else if(CHECK_GETS == 0){
        VELOCITY_BUFF[VELOCITY_BUFF_IDX] = i;
        VELOCITY_BUFF_IDX++;
    }
}

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

void putch_USART1(char data)
{
    while(!(UCSR1A & (1<<UDRE1))); // UDRE flag is USART Data Register Empty
    UDR1 = data;
}

void puts_USART1(char *str)
{
    unsigned char i = 0;
    unsigned char x = 0;
    for(i = 0; str[i] ;i++){
        putch_USART1(str[i]);
    }
    for(x = 0; x<i; x++){
        *(str++) = 0;
    }
}

void puts_Modbus1(char *str,char IDX)
{
    unsigned char i = 0;
    UCSR0B &= ~(1<<RXEN0);
    if(TIMER2_OVERFLOW>0)
    {       
        for(i = 0;i<IDX;i++) putch_USART1(*(str+i));
        for(i = 0; i<IDX; i++) *(str+i) = 0;
    }
    UCSR0B |= (1<<RXEN0);
}

void putch_USART0(char data)
{
    while(!(UCSR0A & (1<<UDRE0))); // UDRE flag is USART Data Register Empty
    UDR0 = data;
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

int RTU_ReedOperate0(char device_address,int starting_address,int data)
{
    char protocol[8];
    unsigned short crc16;
    int i=0;
    //PACKET_BUFF_IDX = 0;

    protocol[0]=device_address;
    protocol[1]=0x04;
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

void Make_MSPEED(float* _velocity, float* _angularV, int* R_RPM, int* L_RPM)
{
    float VelocityR = 0;
    float VelocityL = 0;

    if(*_velocity>=0){
        *_angularV = -(*_angularV);
    }

    VelocityR = *_velocity+(*_angularV*Length)/2;
    VelocityL = *_velocity-(*_angularV*Length)/2;

    *R_RPM = (int)(VelocityR*(60/(0.4)*Gearratio));
    *L_RPM = (int)(VelocityL*(60/(0.4)*Gearratio));

    if( ((*R_RPM<300)&&(*R_RPM>-300))&&((*L_RPM<300)&&(*L_RPM>-300))){
        *R_RPM = 0;
        *L_RPM = 0;     
    }
}

void oper_Disapath(int velocity_R, int velocity_L)
{
    RTU_WriteOperate0(R,(unsigned int)121,(int)(velocity_R));
    delay_ms(1);

    RTU_WriteOperate0(L,(unsigned int)121,(int)-(velocity_L));
    delay_ms(1);
    
    RTU_WriteOperate0(R,(unsigned int)120,(int)(START));
    delay_ms(1);

    RTU_WriteOperate0(L,(unsigned int)120,(int)(START));
    delay_ms(1);
}

int get_RPM(char *str,char IDX, int* goal)
{
    unsigned char i = 0;
    unsigned int RPM = 0;

    if(PACKET_BUFF[1]!=0x07){
        RPM = (int)(PACKET_BUFF[5] << 8)+ (int)(PACKET_BUFF[6]);
        *goal = (int)(PACKET_BUFF[3] << 8) + (int)(PACKET_BUFF[4]);
        for(i = 0; i<IDX; i++) *(str+i) = 0;
        if(RPM == -1)RPM = 0;
        return RPM;
    }
}