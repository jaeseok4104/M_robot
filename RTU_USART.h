#ifndef __RTU_USART_H
#define __RTU_USART_H

#define bps_115200 0x0007

#define POLYNORMIAL 0xA001
#define R 0x01
#define L 0x02
#define START 1
#define STOP 2

#define Length 0.279
#define Gearratio 20

#define Circular 57.29                      // 180 / PI

extern unsigned char TIMER2_OVERFLOW;
extern unsigned char PACKET_BUFF[];
extern unsigned char PACKET_BUFF_IDX;

extern unsigned int TIMER0_OVERFLOW;
extern unsigned char VELOCITY_BUFF[];
extern unsigned char VELOCITY_BUFF_IDX;
extern unsigned char CHECK_GETS;

void usart1_init(int bps);
void usart0_init(int bps);
void putch_USART1(char data);
void puts_USART1(char *str);
void puts_Modbus1(char *str,char IDX);
void putch_USART0(char data);
void puts_USART0(char *str,char IDX);
unsigned short CRC16(unsigned char *puchMsg, int usDataLen);
int RTU_WriteOperate0(char device_address,int starting_address,int data);
int RTU_ReedOperate0(char device_address,int starting_address,int data);
void Make_MSPEED(float* _velocity, float* _angularV, int* R_RPM, int* L_RPM);
void oper_Disapath(int velocity_R, int velocity_L);
int get_RPM(char *str,char IDX, int* goal);

#endif