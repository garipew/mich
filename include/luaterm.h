#ifndef SELECTOR_H
#define SELECTOR_H

#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>


lua_State* lua_create_thread(); 
lua_State* lua_fork_thread();
int lua_raw_read(lua_State*);
int lua_load_term(lua_State*);
int lua_disable_canon(lua_State*);
int lua_enable_canon(lua_State*);
int lua_restore_term(lua_State*);
int lua_get_fd(lua_State*);
int lua_isatty(lua_State*);
int lua_get_size(lua_State*);
#endif
