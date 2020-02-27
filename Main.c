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

unsigned int TIMER1_OVERFLOW = 0;

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
    int diameter = 0;
    
    int currentRPM_R = 0;
    int currentRPM_L = 0;
    float currentV_R = 0;
    float currentV_L = 0;
    int goal_current_R = 0;
    int goal_current_L = 0;
    float goal_currentV_R = 0;
    float goal_currentV_L = 0;
    

    float d_velocity = 0;
    float d_angularV = 0;
    float control_time = 0;
    float g_velocity = 0;
    float g_angularV = 0;

    float d_x = 0;
    float d_y = 0;
    float d_angular = 0;
    int d_angular_circula = 0;
    float g_x = 0;
    float g_y = 0;
    float g_angular = 0;
    int g_angular_circula = 0;

    float TIMER1_TIME = 0;
    float TIMER0_TIME = 0;
    float TIMER0_TIME_print = 0;

    char rootine_test = 0;
    char STOP_FLAG = 0;


    float hall_x = 0;
    float hall_y = 0;
    float hall_angular = 0;
    int hall_angular_circula = 0;
    float hall_velocity = 0;

    float motorR_distance = 0;
    float motorL_distance = 0;
    float a = 0;
    
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
            sscanf(VELOCITY_BUFF,"<%d>", &diameter);
            // if(!del_ms){
            //     d_x = 0;
            //     d_y = 0;
            //     d_angular = 0;
            // }
            if((float)(0.5*0.75)<diameter)
            {
                del_s = (float)((diameter + (0.75*0.5))/0.5);
                del_s -= 0.75;
            }
            else del_s = (float)(((0.75*0.5)+diameter)/0.5);

            del_ms = (int)(del_s*1000);
            // v_buff = (float)velocity/1000;
            v_buff = 0.5;
            a_buff = (float)angularV/1000;
            
            Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);

            oper_Disapath(velocity_R, velocity_L);

            TIMER1_TIME = 0;
            TIMER1_OVERFLOW = 0;
            TCNT1L = 0;            

            // rootine_test = 1;
            STOP_FLAG = 1;
            CHECK_GETS = 0;
            UCSR1B |=(1<<RXEN1);
        }

        // if(rootine_test == 0)
        // {
        //     v_buff = 0.15;
        //     a_buff = 0;
        //     if(d_x<0.95)
        //     {
        //         Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);
        //         oper_Disapath(velocity_R,velocity_L);
        //         STOP_FLAG = 1;
        //     }
        //     else{
        //         if(STOP_FLAG) a = TIMER0_TIME_print;
        //         if(TIMER0_TIME_print > a+2) rootine_test = 1;
        //         oper_Disapath(0,0);
        //         STOP_FLAG = 0;
        //     }
        // }
        // else if(rootine_test == 1)
        // {
        //     v_buff = 0;
        //     a_buff = -0.7;
        //     if(d_angular_circula<85)
        //     {
        //         Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);
        //         oper_Disapath(velocity_R,velocity_L);
        //         STOP_FLAG = 1;
        //     }
        //     else{
        //         if(STOP_FLAG) a = TIMER0_TIME_print;
        //         if(TIMER0_TIME_print > a+2) rootine_test = 2;
        //         oper_Disapath(0,0);
        //         STOP_FLAG = 0;
        //     }
        // }
        // else if(rootine_test == 2)
        // {      
        //     v_buff = 0.15;
        //     a_buff = 0;
        //     if(d_y<0.95)
        //     {
        //         Make_MSPEED(&v_buff, &a_buff, &velocity_R, &velocity_L);
        //         oper_Disapath(velocity_R,velocity_L);
        //         STOP_FLAG = 1;
        //     }
        //     else{
        //         if(STOP_FLAG) a = TIMER0_TIME_print;
        //         if(TIMER0_TIME_print > a+2) rootine_test = 3;
        //         oper_Disapath(0,0);
        //         STOP_FLAG = 0;
        //     }
        // }

        TIMER1_TIME = (float)(TIMER1_OVERFLOW*255 +(int)TCNT1L)*0.0694444;

        if(del_ms<TIMER1_TIME)
        {
            oper_Disapath(0,0);   
            TIMER1_OVERFLOW = 0;
            v_buff = 0;
            a_buff = 0;
            STOP_FLAG = 0;
        }
        if(goal_currentV_R==0 && goal_currentV_L==0) TIMER0_TIME_print = 0;

        delay_ms(5);
        RTU_ReedOperate0(R, (unsigned int)2 ,(unsigned int)2);
        delay_ms(5);
        currentRPM_R = get_RPM(PACKET_BUFF, PACKET_BUFF_IDX, &goal_current_R);
        RTU_ReedOperate0(L, (unsigned int)2 ,(unsigned int)2);
        delay_ms(5);
        currentRPM_L = -get_RPM(PACKET_BUFF, PACKET_BUFF_IDX, &goal_current_L);

        currentV_R = (float)(currentRPM_R/(60/(Pi*0.125)*Gearratio));
        currentV_L = (float)(currentRPM_L/(60/(Pi*0.125)*Gearratio));

        goal_currentV_R = (float)(goal_current_R/(60/(Pi*0.125)*Gearratio));
        goal_currentV_L = (float)(-goal_current_L/(60/(Pi*0.125)*Gearratio));

        d_velocity = (currentV_R + currentV_L)/2;
        d_angularV = (currentV_R-currentV_L)/Length;
        g_velocity = (goal_currentV_R+goal_currentV_L)/2;
        g_angularV = (goal_currentV_R-goal_currentV_L)/Length;

        control_time = ((TIMER0_OVERFLOW)*255 + TCNT0)*0.0000694444;
        TIMER0_OVERFLOW = 0;
        TCNT0 = 0;

        d_angular += control_time*d_angularV;
        d_x += d_velocity*control_time*cos(d_angular);
        d_y += d_velocity*control_time*sin(d_angular);
        d_angular_circula = (int)(d_angular*Circular);

        g_angular += control_time*g_angularV;
        g_x += g_velocity*control_time*cos(g_angular);
        g_y += g_velocity*control_time*sin(g_angular);
        g_angular_circula = (int)(g_angular*Circular);
        
        // motorR_distance = (float)(MOTORR_HALL*0.1325*Pi/160);
        // motorL_distance = (float)(MOTORL_HALL*0.1325*Pi/160);
        motorR_distance = (float)(MOTORR_HALL*0.125*Pi/160);
        motorL_distance = (float)(MOTORL_HALL*0.125*Pi/160);
        
        TIMER0_TIME += control_time;
        if(TIMER0_TIME>0.1){
            TIMER0_TIME_print += TIMER0_TIME;
            MOTORR_HALL = 0;
            MOTORL_HALL = 0;

            hall_velocity = (float)((motorR_distance+motorL_distance)/(2*TIMER0_TIME));
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
            sprintf(BUFF, "%.3f, %.3f, %.3f, %.3f, %.3f, %d\n",TIMER0_TIME_print,g_velocity, hall_velocity, g_x, hall_x, del_ms);

            // sprintf(BUFF, "%4d, %4d\n", MOTORR_HALL, MOTORL_HALL);
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