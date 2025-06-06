CC=gcc
INCLUDE=-I./include
CFLAGS=-shared $(INCLUDE) -fPIC -I/usr/include/lua5.3


luaterm: src/luaterm.c include/luaterm.h build/termiel.o
	$(CC) $(CFLAGS) -o build/luaterm.so include/luaterm.h src/luaterm.c build/termiel.o

all: luaterm unb

unb: src/unb.c build/termiel.o
	$(CC) $(INCLUDE) -o build/unb src/unb.c build/termiel.o


build/termiel.o: src/termiel.c include/termiel.h
	$(CC) $(CFLAGS) -o build/termiel.o -c src/termiel.c

clean:
	rm -rf build/*.o build/luaterm.so build/unb
