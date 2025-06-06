#ifndef INPUT_H
#define INPUT_H

#include <termios.h>
#include <stddef.h>

#define CTRLD 0x4


extern struct termios fixed;
extern struct termios unfixed;
extern int termfd;

void load_term(int);
void disable_canon(unsigned int, unsigned int);
void enable_canon();
void restore_term();
int raw_read(int, char*);
#endif 
