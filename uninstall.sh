#!/usr/bin/env bash

LUA=$(command -v lua)
LUA_VERSION=$($LUA -e 'print(string.match(_VERSION, "%d+%.%d+"))')

rm -rf /usr/local/bin/mich
rm -rf /usr/local/lib/lua/$LUA_VERSION/luaterm.so
