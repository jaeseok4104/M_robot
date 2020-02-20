#include "ext_int.h"
////2채배
void EXT_INT_init(void)
{
    EICRB = (1<<ISC50)|(1<<ISC60)|(1<<ISC70)|(1<<ISC40);
    EIMSK = (1<<INT4)|(1<<INT5)|(1<<INT6)|(1<<INT7);

    DDRE.4 = 0;
    DDRE.5 = 0;
    DDRE.6 = 0;
    DDRE.7 = 0;
}

interrupt [EXT_INT4] void hall_sensor_detection1(void)
{
    if(RHALL_A != RHALL_B) MOTORR_HALL++;
    else MOTORR_HALL--;    
}

interrupt [EXT_INT5] void hall_sensor_detection2(void)
{
    if(RHALL_A != RHALL_B) MOTORR_HALL--;
    else MOTORR_HALL++;    
}

interrupt [EXT_INT6] void hall_sensor_detection3(void)
{
    if(LHALL_B != LHALL_A) MOTORL_HALL--;
    else MOTORL_HALL++;
}

interrupt [EXT_INT7] void hall_sensor_detection4(void)
{
    if(LHALL_A != LHALL_B) MOTORL_HALL++;
    else MOTORL_HALL--;
}