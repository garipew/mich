LUA?=$(shell command -v lua)
LUA_VERSION=$(shell $(LUA) -e 'print(string.match(_VERSION, "%d+%.%d+"))')

CC=gcc
INCLUDE=-I./include
CFLAGS=-shared $(INCLUDE) -fPIC -I/usr/include/lua$(LUA_VERSION)


build: src/luaterm.c include/luaterm.h termiel.o
	$(CC) $(CFLAGS) -o build/luaterm.so include/luaterm.h src/luaterm.c build/termiel.o

termiel.o: src/termiel.c include/termiel.h
	$(CC) $(CFLAGS) -o build/termiel.o -c src/termiel.c

clean:
	rm -rf build/*.o build/luaterm.so

.PHONY: build clean
