#!/usr/bin/env bash

LUA=$(command -v lua)
LUA_VERSION=$($LUA -e 'print(string.match(_VERSION, "%d+%.%d+"))')

mkdir -p build
make build LUA=$LUA

cp main.lua /usr/local/bin/mich
mkdir -p /usr/local/lib/lua/$LUA_VERSION
cp build/luaterm.so /usr/local/lib/lua/$LUA_VERSION/luaterm.so
