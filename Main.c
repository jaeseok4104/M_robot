#include <mega128.h>
#include <stdio.h>
#include <delay.h>
#include <math.h>

#define bps_115200 0x0007
    
#define POLYNORMIAL 0xA001

#define CHARACTER3_5 25
#define TRUE 0
#define FALSE 1

#define R 0x01
#define L 0x02
#define START 1
#define STOP 2

#define Length 0.29
#define Gearratio 25

unsigned char TIMER2_OVERFLOW = 0;
unsigned char PACKET_BUFF[100] = {0,};
unsigned char PACKET_BUFF_IDX = 0;

unsigned int TIMER0_OVERFLOW = 0;
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
    TCCR0 = (1<<CS02)|(1<<CS01)|(1<<CS00); // CTC모드, 1024분주
    TIMSK = (1<<OCIE2)|(1<<TOIE0);
}

void putch_USART1(char data)
{
    while(!(UCSR1A & (1<<UDRE1))); // UDRE flag is USART Data Register Empty
    UDR1 = data;
}

//USART 문자열 송신
// void puts_USART1(char *str,char IDX)
// {
//     unsigned char i = 0;

//     for(i = 0;i<IDX;i++)
//     {
//         putch_USART1(*(str+i));
//     }

//     for(i = 0; i<IDX; i++)
//     {
//         *(str+i) = 0;
//     }
// }

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

// void puts_USART1(char *str,char IDX)
// {
//     unsigned char i = 0;

//     while(*str != 0)
//     {
//         putch_USART1(*(str+i));
//         i++;
//     }

//     for(i = 0; i<IDX; i++)
//     {
//         *(str+i) = 0;
//     }
// }

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

    VelocityR = *_velocity+(*_angularV*Length)/4;
    VelocityL = *_velocity-(*_angularV*Length)/4;

    *R_RPM = (int)(152.788*VelocityR*Gearratio);
    *L_RPM = (int)(152.788*VelocityL*Gearratio);

    if( ((*R_RPM<300)&&(*R_RPM>-300))&&((*L_RPM<300)&&(*L_RPM>-300))){
        *R_RPM = 0;
        *L_RPM = 0;     
    }
}

void oper_Disapath(int velocity_R, int velocity_L)
{
    RTU_WriteOperate0(R,(unsigned int)121,(int)(velocity_R));
    delay_ms(5);

    RTU_WriteOperate0(L,(unsigned int)121,(int)-(velocity_L));
    delay_ms(5);
    
    RTU_WriteOperate0(R,(unsigned int)120,(int)(START));
    delay_ms(5);

    RTU_WriteOperate0(L,(unsigned int)120,(int)(START));
    delay_ms(5);
}

int get_RPM(char *str,char IDX, int* goal)
{
    unsigned char i = 0;
    unsigned int RPM = 0;

    RPM = (int)(PACKET_BUFF[5] << 8)+ (int)(PACKET_BUFF[6]);
    *goal = (int)(PACKET_BUFF[3] << 8) + (int)(PACKET_BUFF[4]);
    for(i = 0; i<IDX; i++) *(str+i) = 0;

    return RPM;
}

// void get_motorSpeed(int* velocity_R, int* velocity_L)
// {
//     RTU_ReedOperate0(R,(unsigned int)3,(unsigned int)2);
//     delay_ms(1);
//     puts_Modbus1(PACKET_BUFF,PACKET_BUFF_IDX);
//     delay_ms(1); 
//     RTU_ReedOperate0(R,(unsigned int)3,(unsigned int)2);
//     delay_ms(1);
//     puts_Modbus1(PACKET_BUFF,PACKET_BUFF_IDX);   
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

interrupt [TIM2_COMP] void timer2_comp(void)
{
    TIMER2_OVERFLOW++;
}

interrupt [TIM0_OVF] void timer0_ovf(void)
{
    TIMER0_OVERFLOW++;
}

void main(void)
{
    float a_buff;
    float v_buff;

    int velocity = 0;
    int angularV = 0;
    int velocity_R = 0;
    int velocity_L = 0;
    int past_velocity_R = 0;
    int past_velocity_L = 0;
    
    // int current_R = 0;
    // int current_L = 0;
    float current_R = 0;
    float current_L = 0;
    int goal_current_R = 0;
    int goal_current_L = 0;

    float d_velocity = 0;
    float d_angularV = 0;
    float control_time = 0;

    float d_x = 0;
    float d_y = 0;
    float d_angular = 0;
    
    unsigned char BUFF[100] = {0,};

    usart1_init(bps_115200);
    usart0_init(bps_115200);
    timer2_init();
    timer0_init();
    SREG |= 0x80;
    DDRB.1 = 1;
    DDRB.2 = 1;
    DDRB.3 = 1;
    delay_ms(5000);
    PORTB.1 = 0;
    PORTB.2 = 1;
    
    TIMER0_OVERFLOW = 0;
    TCNT0 = 0;
    while(1)
    {
        if(CHECK_GETS)
        {
            // TIMER0_OVERFLOW = 0;
            // TCNT0 = 0;
            
            PORTB.1 = 1;
            
            UCSR1B &= ~(1<<RXEN1);
            sscanf(VELOCITY_BUFF,"<%d,%d>", &velocity, &angularV);
            
            v_buff = (float)velocity/1000;
            a_buff = (float)angularV/1000;
            
            Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);
            //sprintf(BUFF,"<%.2f,%.f2>", v_buff, a_buff);
            //sprintf(BUFF,"<%d,%d>", velocity_R, velocity_L);
            //puts_USART1(BUFF,VELOCITY_BUFF_IDX);

            past_velocity_R = velocity_R;
            past_velocity_L = velocity_L;

            oper_Disapath(velocity_R, velocity_L);
            
            CHECK_GETS = 0;
            UCSR1B |=(1<<RXEN1);
            PORTB.1 = 0;
        }

        RTU_ReedOperate0(R, (unsigned int)2 ,(unsigned int)2);
        delay_ms(5);
        // current_R = get_RPM(PACKET_BUFF, PACKET_BUFF_IDX, &goal_current_R);
        current_R = (float)get_RPM(PACKET_BUFF, PACKET_BUFF_IDX, &goal_current_R)/(152.788*Gearratio);
        delay_ms(5);
        RTU_ReedOperate0(L, (unsigned int)2 ,(unsigned int)2);
        delay_ms(5);
        // current_L = -get_RPM(PACKET_BUFF, PACKET_BUFF_IDX, &goal_current_L);
        current_L = -(float)get_RPM(PACKET_BUFF, PACKET_BUFF_IDX, &goal_current_L)/(152.788*Gearratio);
        delay_ms(5);

        d_velocity = (current_R + current_L)/2;
        d_angularV = (2*(current_R-current_L))/Length;
        control_time = ((TIMER0_OVERFLOW)*255 + TCNT0)* 0.000069444;

        d_angular += (control_time*d_angularV);

        d_x += d_velocity*cos(control_time*d_angularV);
        d_y += d_velocity*sin(control_time*d_angularV);
        
        TIMER0_OVERFLOW = 0;
        TCNT0 = 0;
        // sprintf(BUFF, "%f, %f, %f\n", d_velocity, d_angularV, control_time);
        sprintf(BUFF, "%f, %f, %f, %f, %f\n", d_x, d_y, d_angular, current_R/1000, current_L/1000);
        // sprintf(BUFF, "%d, %d\n", current_R, goal_current_R);
        // sprintf(BUFF, "%d, %d, %d, %d\n", current_R, current_L, goal_current_R, goal_current_L);
        puts_USART1(BUFF);
    }
}