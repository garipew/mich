#include "termiel.h"
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
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


int main(int argc, char** argv){
	if(argc > 1 &&
		 argv[1][0] == '-' && argv[1][1] == 'h'){
		printf("%s", help);
		return 0;
	}
	setvbuf(stdout, NULL, _IONBF, 0);
	load_term(STDIN_FILENO);
	disable_canon(0, 100);

	ssize_t n;
	char byte;

	while(1){
		if((n = raw_read(0, &byte)) > 0){
			if(byte == CTRLD){
				printf("\n");
				break;
			}
			printf("%c", byte);
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
