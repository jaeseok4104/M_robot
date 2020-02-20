#ifndef PID_H
#define PID_H

#define Kp 1
#define Ki 0
#define Kd 0

int PID_Controller(int Goal, float now, float* integral, float* Err_previous);

#endif