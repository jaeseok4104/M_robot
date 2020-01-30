#include <mega128.h>
#include <stdio.h>
#include <delay.h>

#define bps_115200 0x0007

#define POLYNORMIAL 0xA001

#define CHARACTER3_5 60 // 0.03msec
#define TRUE 0
#define FALSE 1

#define R 0x01
#define L 0x02
#define START 1
#define STOP 2

#define Length 0.29
#define Gearratio 25

//////////US/////////////////
#define Inches 0x50
#define Centimeters 0x51
#define microSec 0x52

#define tau 0.1 //LOWPASS_FILTER
#define ts 0.7//SAMPLING CYCLE

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

////////////////init function/////////////
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

void timer0_init(void)
{
    TCCR0 = (1<<WGM01)|(1<<CS02)|(1<<CS01)|(1<<CS00); // CTC모드, 1024분주
    OCR0 = 40;
    TIMSK = (1<<OCIE2)|(1<<OCIE0);
}

void timer1_init(void)
{
    // TCCR1A = (1<<COM1B0);
    TCCR1B = (1<<WGM13)|(1<<WGM12)|(1<<CS12)|(1<<CS10);; // WGM bit setting

    OCR1B = 1008;
    ICR1 = 1200;//1200; //664
    TIMSK |= (1<<OCIE1B);
}

void timer2_init(void)
{
    //TIMER2
    TCCR2 = (1<<WGM21)|(1<<CS21)|(1<<CS20);// CTC모드, 1분주

    OCR2 = 100;
    TIMSK = (1<<OCIE2)|(1<<OCIE0); 
    //TIMSK = (1<<OCIE2);
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

/////////////////////////////////////MOTOR///////////////////////////////////////
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
void oper_Disapath(int velocityR, int velocityL, int p_velocity_R, int p_velocity_L)
{
    if((p_velocity_R==0) && (velocityR != 0))
    {
        RTU_WriteOperate0(R,(unsigned int)120,START);
        delay_ms(5);
    }
    else if((p_velocity_R!=0) && (velocityR == 0))
    {
        RTU_WriteOperate0(R,(unsigned int)120,STOP);
        delay_ms(5); 
    }
    if((p_velocity_L==0) && (velocityL != 0))
    {
        RTU_WriteOperate0(L,(unsigned int)120,START);
        delay_ms(5);
    }
    else if((p_velocity_L!=0) && (velocityL == 0))
    {
        RTU_WriteOperate0(L,(unsigned int)120,STOP);
        delay_ms(5); 
    }    
}

////////////////////////////////////TWI_Ultra_Sonic//////////////////////////////////////////////////

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

/////////////////////ISR//////////////////////////////////

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

interrupt [TIM2_COMP] void timer2_comp(void)
{
    TIMER2_OVERFLOW++;
}

interrupt [TIM0_COMP] void timer0_comp(void)
{
    TIMER0_OVERFLOW++;
}

interrupt [TIM1_COMPB] void timer1_compb(void)
{
    SRF02_CONVERTING_FLAG = 1;
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

    float robot_position_x = 0;
    float robot_position_y = 0;
    unsigned char BUFF[100] = {0,};

    /////////////////Ultra sonic/////////////////////////
    unsigned char USID[10] = {0xE0, 0xE2, 0xE4, 0xE6, 0xE8, 0xEA, 0xEC, 0xEE};
    unsigned char us_range[10] = {0,};
    unsigned char pre_us_range[10] = {0,};

    usart1_init(bps_115200);
    usart0_init(bps_115200);
    timer2_init();
    SREG |= 0x80;

    delay_ms(5000);
    
    // SRF02_CONVERTING_FLAG = 0;
    while(1)
    {
        // if(SRF02_WAIT_FLAG == 0){
        //     Start_SRF02_Conv(USID[0],Centimeters);
        //     TCNT1H = 0;
        //     TCNT1L = 0;
        //     SRF02_WAIT_FLAG = 1;
        // }

        if(CHECK_GETS == 0)
        {   
            UCSR1B &= ~(1<<RXEN1);
            sscanf(VELOCITY_BUFF,"<%d,%d>", &velocity, &angularV);
            UCSR1B |=(1<<RXEN1);
            
            v_buff = (float)velocity/1000;
            a_buff = (float)angularV/1000;
            
            Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);

            // if(SRF02_CONVERTING_FLAG == 1 && SRF02_WAIT_FLAG == 1){
            //     us_range[0] = Get_SRF02_Range(0xE0);

            //     us_range[0] = ( tau * pre_us_range[0] + ts * us_range[0] ) / (tau + ts) ;

            //     SRF02_CONVERTING_FLAG = 0;
            //     SRF02_WAIT_FLAG = 0;
            // }

            sprintf(BUFF,"<%.2f,%.f2>", v_buff, a_buff);
            puts_USART1(BUFF,VELOCITY_BUFF_IDX);

            RTU_WriteOperate0(R,(unsigned int)121,(int)(velocity_R));
            delay_ms(3);

            RTU_WriteOperate0(L,(unsigned int)121,(int)-(velocity_L));
            delay_ms(3);
            
            RTU_WriteOperate0(R,(unsigned int)120,(int)(START));
            delay_ms(3);

            RTU_WriteOperate0(L,(unsigned int)120,(int)(START));
            delay_ms(3);
        }
    }
}