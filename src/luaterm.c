#include "luaterm.h"
#include "termiel.h"


static const luaL_Reg luaterm[] = {
	{"raw_read", lua_raw_read},
	{"restore_term", lua_restore_term},
	{"enable_canon", lua_enable_canon},
	{"disable_canon", lua_disable_canon},
	{"load_term", lua_load_term},
	{"get_fd", lua_get_fd},
	{"isatty", lua_isatty},
	{NULL, NULL}
};


int luaopen_luaterm(lua_State *L){
	luaL_newlib(L, luaterm);
	return 1;
}


int lua_load_term(lua_State* L){
	int fd = luaL_checkinteger(L, 1);
	load_term(fd);
	return 0;
}


int lua_disable_canon(lua_State* L){
	unsigned int bytes, time;
	bytes = luaL_checkinteger(L, 1);
	time = luaL_checkinteger(L, 2);

	disable_canon(bytes, time);	
	return 0;
}


int lua_enable_canon(lua_State* L){
	enable_canon();
	return 0;
}


int lua_restore_term(lua_State* L){
	restore_term();
	return 0;
}


int lua_raw_read(lua_State* L){
	char byte;
	
	int read_bytes = raw_read(termfd, &byte);
	lua_pushlstring(L, &byte, 1);	
	return 1;
}


int lua_get_fd(lua_State* L){
	FILE** f = (FILE**)luaL_checkudata(L, 1, "FILE*");
	if(f == NULL || *f == NULL){
		return luaL_error(L, "expected a valid file handle");
	}
	int fd = fileno(*f);
	lua_pushinteger(L, fd);
	return 1;
}


int lua_isatty(lua_State* L){
	int fd = luaL_checkinteger(L, 1);
	lua_pushinteger(L, isatty(fd));
	return 1;
}
