#include <mega128.h>
#include <stdio.h>
#include <delay.h>
#include <math.h>

#define bps_115200 0x0007
    
#define POLYNORMIAL 0xA001

#define CHARACTER3_5 60 // 0.03msec
#define TRUE 0
#define FALSE 1

#define R 0x01
#define L 0x02
#define START 1
#define STOP 2

#define Length 0.281
#define Gearratio 20

#define Circular 57.29                      // 180 / PI


/////////////////////////TWI//////////////////////////
#define Inches 0x50
#define Centimeters 0x51
#define microSec 0x52
#define USID 0xE4

#define CommandReg 0
#define Unused 1
#define RangeHighByte 2
#define RangeLowByte 3

#define TWI_START 0x08
#define MT_REPEATED_START 0x10
#define MT_SLAW_ACK 0x18
#define MT_DATA_ACK 0x28
#define MT_SLAR_ACK 0x40
#define MT_DATA_NACK 0x58

#define ts 0.070         /// 샘플링 시간
#define tau 0.1         /// 시정수

//////////////////////integer////////////////
unsigned char TIMER2_OVERFLOW = 0;
unsigned char PACKET_BUFF[100] = {0,};
unsigned char PACKET_BUFF_IDX = 0;

unsigned int TIMER0_OVERFLOW = 0;
unsigned char VELOCITY_BUFF[20] = {0,};
unsigned char VELOCITY_BUFF_IDX = 0;

///////////////FLAG//////////////////////
unsigned char SRF02_CONVERTING_FLAG = 0;
unsigned char SRF02_WAIT_FLAG = 0;
unsigned char CHECK_GETS = 0;

unsigned char CHECK_CONTROL = 0;
unsigned int TIMER1_OVERFLOW = 0;

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
    TCCR2 = (1<<WGM21)|(1<<CS21)|(1<<CS20);// CTC모드, 1분주

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

void TWI_Init(){
    TWBR = 10;
    TWSR = 0;
    TWCR = 0;
}


////////////////////USART RTX/////////////////////////////////
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
    // if(TIMER2_OVERFLOW>0)
    // {       
        for(i = 0;i<IDX;i++) putch_USART1(*(str+i));
        for(i = 0; i<IDX; i++) *(str+i) = 0;
    // }
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

///////////////////////Modbus///////////////////////////////////////
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
    PACKET_BUFF_IDX = 0;

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
    PACKET_BUFF_IDX = 0;

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
    // VelocityR = *_velocity+(*_angularV*Length)/4;
    VelocityL = *_velocity-(*_angularV*Length)/2;
    // VelocityL = *_velocity-(*_angularV*Length)/4;

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
    if(PACKET_BUFF[1] == 0x04){
        RPM = (int)(PACKET_BUFF[5] << 8)+ (int)(PACKET_BUFF[6]);
        *goal = (int)(PACKET_BUFF[3] << 8) + (int)(PACKET_BUFF[4]);
        for(i = 0; i<IDX; i++) *(str+i) = 0;

        return RPM;
    }
    return -1;
}

///////////////// TWI /////////////////////////////
unsigned char TWI_Read(unsigned char addr, unsigned char regAddr)
{
    unsigned char Data;
    TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));//Start조건 전송
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=TWI_START));
    
    TWDR = addr&(~0x01);                //쓰기 위한 주소 전송
    TWCR = ((1<<TWINT)|(1<<TWEN));
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAW_ACK));
    
    TWDR = regAddr;                     //Reg주소 전송
    TWCR = ((1<<TWINT)|(1<<TWEN));
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
    
    TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA)); //Repeated start 전송
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_REPEATED_START));
    
    TWDR = addr|0x01;                       //읽기 위한 주소 전송
    TWCR = ((1<<TWINT)|(1<<TWEN));
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAR_ACK));
                                    
    
    TWCR = ((1<<TWINT)|(1<<TWEN));                
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_NACK));
    Data = TWDR;                        //Data읽기
    
    TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTO));
    
    return Data;    
}

void TWI_Write(unsigned char addr, unsigned char Data[],int NumberOfData)
{
    int i=0;
    
    TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTA));
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=TWI_START));  
    
    TWDR = addr&(~0x01);
    TWCR = ((1<<TWINT)|(1<<TWEN));  
    while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_SLAW_ACK));
    
    for(i=0;i<NumberOfData;i++){
        TWDR = Data[i];
        TWCR = ((1<<TWINT)|(1<<TWEN));  
        while(((TWCR & (1 << TWINT)) == 0x00) || ((TWSR & 0xf8)!=MT_DATA_ACK));
    }
    
    TWCR = ((1<<TWINT)|(1<<TWEN)|(1<<TWSTO));
}


void Start_SRF02_Conv(unsigned char Adress, unsigned char mode){
    unsigned char ConvMode[2] = {0x00,};
    ConvMode[1] = mode;
    TWI_Write(Adress,ConvMode,2);
}

void Change_SRF02_Adress(unsigned char nowAdress, unsigned char changeAdress)
{
    unsigned char sequense1[2] = {0x00,0xA0};
    unsigned char sequense2[2] = {0x00,0xAA};
    unsigned char sequense3[2] = {0x00,0xA5};
    unsigned char sequense4[2] = {0x00,};
    sequense4[1] = changeAdress;
    TWI_Write(nowAdress,sequense1,2);
    delay_ms(1);
    TWI_Write(nowAdress,sequense2,2);
    delay_ms(1);
    TWI_Write(nowAdress,sequense3,2);
    delay_ms(1);
    TWI_Write(nowAdress,sequense4,2);
    delay_ms(1);
}

unsigned int Get_SRF02_Range(unsigned char Adress)
{
    unsigned int range;
    unsigned char High = 0,Low = 0;

    High = TWI_Read(Adress, RangeHighByte);
    if(High == 0xFF){

        return 0;
    }
    Low = TWI_Read(Adress, RangeLowByte);
    range = (High<<8)+Low;
    
    return range;
}

void Start_SRF02_Conv_arr(unsigned char ID)
{
    if(SRF02_WAIT_FLAG == 0){
        Start_SRF02_Conv(ID,Centimeters);
        TCNT1H = 0;
        TCNT1L = 0;
        SRF02_WAIT_FLAG = 1;
    }
}

void Get_SRF02_Range_filter(unsigned char ID, unsigned int* range, unsigned int* pre_range, unsigned int *no_filter)
{
    if(SRF02_CONVERTING_FLAG == 1 && SRF02_WAIT_FLAG == 1){
        *no_filter = Get_SRF02_Range(ID);

        *range = ( tau * (*pre_range) + ts * (*no_filter) ) / (tau + ts) ; // low pass -filter

        // sprintf(char_buff, "%d,%d\n", *no_filter, *range);
        // puts_USART1(char_buff);

        *pre_range = *range;
        SRF02_CONVERTING_FLAG = 0;
        SRF02_WAIT_FLAG = 0;
        
    }
}

/////////////////////ISR//////////////////////////////////

interrupt [USART0_RXC] void usart0_rxc(void)
{
    // if(((TCNT2 < CHARACTER3_5) && (TIMER2_OVERFLOW == 0)) || PACKET_BUFF_IDX == 0)
    // {
        PACKET_BUFF[PACKET_BUFF_IDX] = UDR0;
        PACKET_BUFF_IDX++;
        // TCNT2 = 0;
    // }
    // else {
    //     PACKET_BUFF_IDX = 0;
    //     PACKET_BUFF[PACKET_BUFF_IDX] = UDR0;
    //     PACKET_BUFF_IDX++;
    //     TCNT2 = 0;
    //     TIMER2_OVERFLOW = 0;
    // }
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

interrupt [TIM1_COMPB] void timer0_comp(void)
{
    TIMER1_OVERFLOW++;
    TCNT1H = 0x00;
    TCNT1L = 0x00;
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
    int del_ms = 0;
    char del_ms_flags = 0;
    
    int currentRPM_R = 0;
    int currentRPM_L = 0;
    float currentV_R = 0;
    float currentV_L = 0;
    int goal_current_R = 0;
    int goal_current_L = 0;

    float d_velocity = 0;
    float d_angularV = 0;
    float control_time = 0;

    float d_x = 0;
    float d_y = 0;
    float d_angular = 0;
    int d_angular_circula = 0;

    float goal_x = 0;
    float goal_y = 0;
    float goal_angular = 0;

    float TIMER1_TIME = 0;
    float TIMER0_TIME = 0;
    
    unsigned char BUFF[500] = {0,};
    

    usart1_init(bps_115200);
    usart0_init(bps_115200);
    timer2_init();
    timer0_init();
    timer1_init();
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
            PORTB.1 = 1;
            
            UCSR1B &= ~(1<<RXEN1);
            sscanf(VELOCITY_BUFF,"<%d,%d,%d>", &velocity, &angularV, &del_ms);
            // sscanf(VELOCITY_BUFF,"<%d,%d,%f,%f,%f>", &velocity, &angularV, &goal_x, &goal_y, goal_angular);

            if(!del_ms){
                d_x = 0;
                d_y = 0;
                d_angular = 0;
            }
            
            v_buff = (float)velocity/1000;
            a_buff = (float)angularV/1000;
            
            Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);

            oper_Disapath(velocity_R, velocity_L);

            TIMER1_TIME = 0;
            TIMER1_OVERFLOW = 0;
            TCNT1L = 0;            

            del_ms_flags = 0;
            CHECK_GETS = 0;
            UCSR1B |=(1<<RXEN1);
            // PORTB.1 = 0;
        }

        TIMER1_TIME = (float)(TIMER1_OVERFLOW*255 +(int)TCNT1L)*0.0694444;

        if(del_ms<TIMER1_TIME && del_ms_flags == 0)
        {
            oper_Disapath(0,0);   
            TIMER1_OVERFLOW = 0;
            v_buff = 0;
            a_buff = 0;
            del_ms_flags = 1;
        }

        RTU_ReedOperate0(R, (unsigned int)2 ,(unsigned int)2);
        delay_ms(5);
        // puts_Modbus1(PACKET_BUFF,PACKET_BUFF_IDX);
        currentRPM_R = get_RPM(PACKET_BUFF, PACKET_BUFF_IDX, &goal_current_R);
        RTU_ReedOperate0(L, (unsigned int)2 ,(unsigned int)2);
        delay_ms(5);
        // puts_Modbus1(PACKET_BUFF,PACKET_BUFF_IDX);
        currentRPM_L = -get_RPM(PACKET_BUFF, PACKET_BUFF_IDX, &goal_current_L);

        currentV_R = (float)(currentRPM_R/(152.788*Gearratio));
        currentV_L = (float)(currentRPM_L/(152.788*Gearratio));

        d_velocity = (currentV_R + currentV_L)/2;
        d_angularV = (currentV_R-currentV_L)/Length;

        control_time = ((TIMER0_OVERFLOW)*255 + TCNT0)*0.0000694444;
        TIMER0_OVERFLOW = 0;
        TCNT0 = 0;

        if((d_velocity!=0) ||(d_angularV!=0)){
            d_x += d_velocity*control_time*cos(control_time*d_angularV);
            d_y += d_velocity*control_time*sin(control_time*d_angularV);
            d_angular += control_time*d_angularV;
            d_angular_circula = (int)(d_angular*Circular);
        }

        TIMER0_TIME += control_time;
        if(TIMER0_TIME>0.1){
            // sprintf(BUFF, "%f, %f, %f, %f\n", d_velocity, v_buff, d_angularV, a_buff);
            // sprintf(BUFF, "%f, %f\n", d_x, d_y,currentRPM_R, current);
            // sprintf(BUFF, "%d, %d, %d\n", velocity, current_R, current_L);
            // sprintf(BUFF, "%.3f, %.3f, %4d\n", d_x, d_y, d_angular_circula);
            sprintf(BUFF, "%d, %d, %d, %d\n", currentRPM_R, currentRPM_L, goal_current_R, -goal_current_L);
            // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f\n", currentV_R, -currentV_L, v_buff, -v_buff);
            puts_USART1(BUFF);
            TIMER0_TIME = 0;
        }

    }
}