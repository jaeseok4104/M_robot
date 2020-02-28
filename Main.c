#include <mega128.h>
#include <stdio.h>
#include <delay.h>
#include <math.h>

#include "TIMER.h"
#include "RTU_USART.h"
#include "ext_int.h"

#define PREDICTION 0.3
unsigned char TIMER2_OVERFLOW = 0;
unsigned char PACKET_BUFF[100] = {0,};
unsigned char PACKET_BUFF_IDX = 0;

unsigned int TIMER0_OVERFLOW = 0;                    
unsigned char VELOCITY_BUFF[20] = {0,};
unsigned char VELOCITY_BUFF_IDX = 0;
unsigned char CHECK_GETS = 0;

long int TIMER1_OVERFLOW = 0;

long int MOTORR_HALL = 0;
long int MOTORL_HALL = 0;

void main(void)
{
    float a_buff;
    float v_buff;

    int velocity = 0;
    int angularV = 0;
    int velocity_R = 0;
    int velocity_L = 0;
    int del_ms = 0;
    float del_s = 0;
    float diameter = 0;
    float d_diameter = 0; 
    float _angular = 0;
    float d__angular = 0;
    int goal = 0;
    char drive_mode = 0;
    
    float control_time = 0;

    float TIMER1_TIME = 0;
    float TIMER0_TIME = 0;
    float TIMER0_TIME_print = 0;

    char STOP_FLAG = 0;


    float hall_x = 0;
    float hall_y = 0;
    float hall_angular = 0;
    int hall_angular_circula = 0;

    float hall_velocity = 0;
    float hall_angularV = 0;

    float motorR_distance = 0;
    float motorL_distance = 0;
    
    unsigned char BUFF[500] = {0,};

    usart1_init(bps_115200);
    usart0_init(bps_115200);
    timer2_init();
    timer0_init();
    timer1_init();
    EXT_INT_init();
    SREG |= 0x80;
    DDRB.1 = 1;
    DDRB.2 = 1;
    DDRB.3 = 1;
    delay_ms(5000);
    
    TIMER0_OVERFLOW = 0;
    TCNT0 = 0;

    while(1)
    {
        if(CHECK_GETS)
        {                      
            UCSR1B &= ~(1<<RXEN1);
            // sscanf(VELOCITY_BUFF,"<%d,%d,%d>", &velocity, &angularV, &del_ms);
            // sscanf(VELOCITY_BUFF,"<%d>", &d_diameter);
            sscanf(VELOCITY_BUFF, "<%d,%d>",&drive_mode, &goal);

            if(drive_mode == 0){
                d_diameter = (float)goal;
                if(d_diameter>0){
                    diameter = (float)(((float)d_diameter/100)-0.05);
                    if((float)(MOTOR_CONT_VELOCITY_MAX_SPEED*MOTOR_DRIVE_VELOCITY_CEL_TIME)<diameter)
                    {
                        del_s = (float)((diameter + (MOTOR_DRIVE_VELOCITY_CEL_TIME*MOTOR_CONT_VELOCITY_MAX_SPEED))/MOTOR_CONT_VELOCITY_MAX_SPEED);
                        del_s -= MOTOR_DRIVE_VELOCITY_CEL_TIME;
                    }
                    else del_s = (float)(((MOTOR_DRIVE_VELOCITY_CEL_TIME*MOTOR_CONT_VELOCITY_MAX_SPEED)+diameter)/MOTOR_CONT_VELOCITY_MAX_SPEED);
                    del_ms = (int)(del_s*1000);
                    v_buff = MOTOR_CONT_VELOCITY_MAX_SPEED;
                    a_buff = 0;
                }
                else{
                    diameter = (float)(((float)d_diameter/100)+0.05);
                    diameter = -diameter;
                    if((float)(MOTOR_CONT_VELOCITY_MAX_SPEED*MOTOR_DRIVE_VELOCITY_CEL_TIME)<diameter)
                    {
                        del_s = (float)((diameter + (MOTOR_DRIVE_VELOCITY_CEL_TIME*MOTOR_CONT_VELOCITY_MAX_SPEED))/MOTOR_CONT_VELOCITY_MAX_SPEED);
                        del_s -= MOTOR_DRIVE_VELOCITY_CEL_TIME;
                    }
                    else del_s = (float)(((MOTOR_DRIVE_VELOCITY_CEL_TIME*MOTOR_CONT_VELOCITY_MAX_SPEED)+diameter)/MOTOR_CONT_VELOCITY_MAX_SPEED);
                    del_ms = (int)(del_s*1000);

                    v_buff = -MOTOR_CONT_VELOCITY_MAX_SPEED;
                    a_buff = 0;
                }
            }
            else if(drive_mode == 1){
                d__angular = (float)goal;
                if(d__angular>0){
                    _angular = (float)((float)(d__angular-14)/Circular);
                    if((float)(MOTOR_CONT_ANGULAR_MAX_SPEED*MOTOR_DRIVE_ANGULAR_CEL_TIME)<_angular)
                    {
                        del_s = (float)((_angular + (MOTOR_DRIVE_ANGULAR_CEL_TIME*MOTOR_CONT_ANGULAR_MAX_SPEED))/MOTOR_CONT_ANGULAR_MAX_SPEED);
                        del_s -= MOTOR_DRIVE_ANGULAR_CEL_TIME;
                    }
                    else del_s = (float)(((MOTOR_DRIVE_ANGULAR_CEL_TIME*MOTOR_CONT_ANGULAR_MAX_SPEED)+_angular)/MOTOR_CONT_ANGULAR_MAX_SPEED);
                    del_ms = (int)(del_s*1000);

                    v_buff = 0;
                    a_buff = MOTOR_CONT_ANGULAR_MAX_SPEED;
                }
                else{
                    _angular = (float)((float)(d__angular+14)/Circular);
                    _angular = -_angular;
                    if((float)(MOTOR_CONT_ANGULAR_MAX_SPEED*MOTOR_DRIVE_ANGULAR_CEL_TIME)<_angular)
                    {
                        del_s = (float)((_angular + (MOTOR_DRIVE_ANGULAR_CEL_TIME*MOTOR_CONT_ANGULAR_MAX_SPEED))/MOTOR_CONT_ANGULAR_MAX_SPEED);
                        del_s -= MOTOR_DRIVE_ANGULAR_CEL_TIME;
                    }
                    else del_s = (float)(((MOTOR_DRIVE_ANGULAR_CEL_TIME*MOTOR_CONT_ANGULAR_MAX_SPEED)+_angular)/MOTOR_CONT_ANGULAR_MAX_SPEED);
                    del_ms = (int)(del_s*1000);
                    
                    v_buff = 0;
                    a_buff = -MOTOR_CONT_ANGULAR_MAX_SPEED;
                }
            }
            // v_buff = (float)velocity/1000;
            // a_buff = (float)angularV/1000;
            TIMER0_TIME_print = 0;
            Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);

            oper_Disapath(velocity_R, velocity_L);

            TIMER1_TIME = 0;
            TIMER1_OVERFLOW = 0;
            TCNT1L = 0;            

            STOP_FLAG = 1;
            CHECK_GETS = 0;
            UCSR1B |=(1<<RXEN1);
        }

        TIMER1_TIME = (float)(TIMER1_OVERFLOW*255 +(int)TCNT1L)*0.0694444;

        if(del_ms<TIMER1_TIME)
        {
            oper_Disapath(0,0);   
            TIMER1_OVERFLOW = 0;
            v_buff = 0;
            a_buff = 0;
            STOP_FLAG = 0;
        }

        // if(goal_currentV_R==0 && goal_currentV_L==0) TIMER0_TIME_print = 0;

        control_time = ((TIMER0_OVERFLOW)*255 + TCNT0)*0.0000694444;
        TIMER0_OVERFLOW = 0;
        TCNT0 = 0;

        motorR_distance = (float)(MOTORR_HALL*0.4/160);
        motorL_distance = (float)(MOTORL_HALL*0.4/160);
        
        TIMER0_TIME += control_time;
        if(TIMER0_TIME>0.01){
            TIMER0_TIME_print += TIMER0_TIME;
            MOTORR_HALL = 0;
            MOTORL_HALL = 0;

            hall_velocity = (float)((motorR_distance+motorL_distance)/(2*TIMER0_TIME));
            hall_angularV = (float)((motorR_distance-motorL_distance)/(Length*TIMER0_TIME));
            hall_angular += (float)((motorR_distance-motorL_distance)/Length);
            hall_x += (float)((motorR_distance+motorL_distance)/2)*cos(hall_angular);
            hall_y += (float)((motorR_distance+motorL_distance)/2)*sin(hall_angular);
            hall_angular_circula = (int)(hall_angular*Circular);
            // sprintf(BUFF, "%f, %f, %f, %f\n", d_velocity, v_buff, d_angularV, a_buff);
            // sprintf(BUFF, "%f, %f\n", currentV_L*control_time, motorL_distance);
            // sprintf(BUFF, "%d, %d, %d\n", velocity, current_R, current_L);
            // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f, %.3f, %d, %d\n", TIMER0_TIME_print, d_x, hall_x, d_y, hall_y, d_angular_circula, hall_angular_circula);
            // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f, %4d, %4d, %.3f\n", d_x, hall_x, d_y, hall_y, d_angular_circula, hall_angular_circula, TIMER0_TIME_print);
            // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f \n",TIMER0_TIME_print, g_velocity, d_velocity, hall_velocity);
            // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f, %.3f, %d\n",TIMER0_TIME_print,g_velocity, hall_velocity, g_x, hall_x, del_ms);
            // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f\n",TIMER0_TIME_print,g_velocity, d_velocity, hall_velocity,);
            sprintf(BUFF, "%.3f, %.3f, %.3f, %d\n", TIMER0_TIME_print, hall_x, hall_y, hall_angular_circula);
            // sprintf(BUFF, "%.3f, %.3f\n", TIMER0_TIME_print, hall_x);

            // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f\n", d_velocity, g_velocity, v_buff, TIMER0_TIME_print);
            // sprintf(BUFF, "%d, %d, %d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f\n", currentRPM_R, -currentRPM_L, goal_current_R, goal_current_L, 
            //                                                   currentV_R, currentV_L, goal_currentV_R, goal_currentV_L,
            //                                                   d_velocity, g_velocity, d_x, g_x, TIMER0_TIME_print);
            // sprintf(BUFF, "%d, %d, %d, %d\n", currentRPM_R, -currentRPM_L, goal_current_R, goal_current_L);
            // sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f\n", currentV_R, -currentV_L, v_buff, -_buff);
            puts_USART1(BUFF);
            TIMER0_TIME = 0;
        }
    }
}