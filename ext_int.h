#ifndef __EXT_INT_H
#define __EXT_INT_H


#define RHALL_A PINE.4
#define RHALL_B PINE.5
#define LHALL_A PINE.7
#define LHALL_B PINE.6

#include <mega128.h>
extern long int MOTORR_HALL;
extern long int MOTORL_HALL;
void EXT_INT_init(void);

#endif
