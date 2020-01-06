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
    PACKET_BUFF_IDX = 0;

    while(*str !=0)
    {
        putch_USART1(*str);
        str++;
    }
}

void putch_USART0(char data)
{
    while(!(UCSR0A & (1<<UDRE0))); // UDRE flag is USART Data Register Empty
    UDR0 = data;
}

void puts_USART0(char *str)
{
    PACKET_BUFF_IDX = 0;

    while(*str !=0)
    {
        putch_USART0(*str);
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
        putch_USART0(*(protocol+i));
    }
}

interrupt [USART0_RXC] void usart0_rxc(void)
{
    PACKET_BUFF[PACKET_BUFF_IDX] = UDR0;
    PACKET_BUFF_IDX++;
}

void main(void)
{
    unsigned char check_cnt = 0;
    usart_init(bps_115200);
    SREG |= 0x80;
    
    while(1)
    {
        RTU_WriteOperate(0x01,0x0079,(int)(1000));
        delay_ms(100);
        //puts_USART1(PACKET_BUFF);
        RTU_WriteOperate(0x01,0x0078,(int)(1));
        delay_ms(300);
    }
}