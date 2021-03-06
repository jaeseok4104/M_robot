#include <PID_controller.h>

int PID_Controller(int Goal, float now, float* integral, float* Err_previous)
{
    long int pErr = 0;
    float dErr = 0;
    long int MV = 0;
    float Err = 0;
    unsigned char BUFF[128]={0,};

    Err = Goal - now; //ERROR

    // pErr = (Kp*Err); // P
    // *integral = *integral +(Ki * Err * Time); // I
    // dErr = (Kd * (Err - *Err_previous)) / Time; // D
    // MV = (long int)(pErr+ *integral + dErr);// PID Control Volume

    //sprintf(BUFF, "pErr=%d, integral=%d, dErr=%d, MV=%d  Err=%d\r\n", (int)pErr, *integral, dErr, MV, (int)Err);
    //string_tx1(BUFF);

    *Err_previous = Err;
    
    return MV;
}