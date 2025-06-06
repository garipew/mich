#include "termiel.h"
#include <stdlib.h>
#include <fcntl.h>


struct termios fixed;
struct termios unfixed;

struct winsize ws;


int termfd;


void load_term(int fd){
	termfd = fd;
	tcgetattr(fd, &fixed);
}


void disable_canon(unsigned int min, unsigned int ms){
	tcgetattr(termfd, &unfixed);
	unfixed.c_lflag &= ~ICANON & ~ECHO;
	unfixed.c_cc[VMIN] = min;
	unfixed.c_cc[VTIME] = ms/100;
	tcsetattr(termfd, TCSANOW, &unfixed);
}


void enable_canon(){
	tcgetattr(termfd, &unfixed);
	unfixed.c_lflag &= ICANON & ECHO;
	tcsetattr(termfd, TCSANOW, &unfixed);
}


void restore_term(){
	tcsetattr(termfd, TCSANOW, &fixed);
}


int raw_read(int fd, char* dst){
	return read(termfd, dst, 1);
}


int get_size(){
	return ioctl(termfd, TIOCGWINSZ, &ws);
}
