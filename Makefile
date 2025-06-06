CC=gcc
CFLAGS=-I./include

all: bin/unb

bin/unb: src/unb.c
	$(CC) $(CFLAGS) -o bin/unb src/unb.c

clean:
	rm -rf bin/unb
