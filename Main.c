#include <mega128.h>
#include <delay.h>

#define bps_115200 0x0007

#define POLYNORMIAL 0xA001

unsigned char PACKET_BUFF[100] = {0,};
unsigned char PACKET_BUFF_IDX = 0;

void usart_init(int bps)
{
    UCSR1A = 0x00;
    UCSR1B = (1<<RXEN1)|(1<<TXEN1)|(1<<RXCIE1); // RXCIE1 bit is recevie interrupt allow 
    UCSR1C = (1<<UCSZ11)|(1<<UCSZ10);
    UCSR1C &= ~(1<<UMSEL1);

    UBRR1H = (unsigned char)((bps>>8)  & 0x00ff);
    UBRR1L = (unsigned char)(bps & 0x00ff);
}

void putch_USART1(char data)
{
    while(!(UCSR1A & (1<<UDRE1))); // UDRE flag is USART Data Register Empty
    UDR1 = data;
}

void puts_USART1(char *str)
{
    PACKET_BUFF_IDX = 0;

    while(*str !=0)
    {
        putch_USART1(*str);
        str++;
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

int RTU_WriteOperate(char device_address,int starting_address,int data)
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
        putch_USART1(*(protocol+i));
    }
}

interrupt [USART1_RXC] void usart1_rxc(void)
{
    PACKET_BUFF[PACKET_BUFF_IDX] = UDR1;
    PACKET_BUFF_IDX++;
}

void main(void)
{
    usart_init(bps_115200);
    SREG |= 0x80;
    
    while(1)
    {
        //delay_ms(500);
        if(PACKET_BUFF_IDX != 0)
            puts_USART1(PACKET_BUFF);
        //RTU_WriteOperate(0x01,0x0079,(int)(0));
    }
}