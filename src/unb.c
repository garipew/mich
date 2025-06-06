#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <stdlib.h>
#include <fcntl.h>


char help[] = ""
"Name\n"
"	unbufferer\n"
"Synopsis\n"
"	unbufferer [-h]\n"
"\n"
"Description\n"
"	The objective of this program is to pipe stdin to stdout in\n"
"	an unbuffered manner, until EOF is reached.\n"
"\n"
"Options\n"
"	-h - Displays this message.\n"
"\n";

 
#define CTRLD 0x4


struct termios fixed;
struct termios mutable;

int broken_pipe = 0;


void load_term(){
	tcgetattr(0, &fixed);
}


void disable_canon(int min, int ms){
	tcgetattr(0, &mutable);
	mutable.c_lflag &= ~ICANON & ~ECHO;	
	mutable.c_cc[VMIN] = min; 
	mutable.c_cc[VTIME] = ms/100; 
	tcsetattr(0, TCSANOW, &mutable);
}


void enable_canon(){
	tcgetattr(0, &mutable);
	mutable.c_lflag &= ICANON & ECHO;
	tcsetattr(0, TCSANOW, &mutable);
}


void restore_term(){
	tcsetattr(0, TCSANOW, &fixed);
}


int main(int argc, char** argv){
	if(argc > 1 &&
		argv[1][0] == '-' && argv[1][1] == 'h'){
		printf("%s", help);
		return 0;
	}

	setvbuf(stdout, NULL, _IONBF, 0);
	load_term();
	disable_canon(0, 100);
	ssize_t n;
	char c;

	while(1){
		if((n = read(0, &c, 1)) > 0){
			if(c == CTRLD){
				printf("\n");
				break;
			}
			printf("%c", c);
		}else{
			if(write(1, "?", 1) == -1){
				break;
			}
		}
	}
	enable_canon();
	restore_term();
	return 0;
}
