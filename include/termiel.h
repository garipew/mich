#ifndef INPUT_H
#define INPUT_H

#include <termios.h>
#include <stddef.h>
#include <unistd.h>
#include <sys/ioctl.h>


extern struct termios fixed;
extern struct termios unfixed;
extern struct winsize ws;
extern int termfd;

void load_term(int);
void disable_canon(unsigned int, unsigned int);
void enable_canon();
void restore_term();
int raw_read(int, char*);
int get_size();
#endif 
