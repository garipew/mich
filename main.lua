#!/usr/bin/env lua

package.cpath = "./build/?.so;"..package.cpath

local luaterm = assert(require("luaterm"))

local isatty = assert(luaterm.isatty(luaterm.get_fd(io.stdin)) == 1,
		"mich must be run from a tty")

help = [[
Name
	mich
Synopsis
	mich [-h] [-d DELIM] [-c CURS] [-s SEL] ITENS

Description
	The objective of this program is to present a minimal UI for
	the user to choose between different itens.

	The itens selected by the user are written to stdout.

	The name comes from Prince Michkin, the main character
	on the novel The Idiot.

Options
	-h - Displays this message.
	-d DELIM - Set the delimiter of the itens to DELIM.
                   The default value of DELIM used is the space
		   character.
	-c CURS - Define the start value of the cursor to CURS.
		  The default value of CURS is 1.
	-s SEL - Defines the maximum amount of itens selected
		 at the same time.
]]


local dimensions = {luaterm.get_size()}
local options_table = {
	["-d"] = 1,
	["-h"] = 0,
	["-c"] = 1,
	["-s"] = 1,
}

--[[
Name
	extract_options

Synopsis
	extract_options(args, options_table)

Description
	This function has the objective to group all of the options
	present in the args table that are registered in options_table.

	The options_table is a map where the keys are the options,
	and the values are the argument count of that option.
	
	The args table is an array, where each element is a argument.

Return Value
	On success, this function returns a map where every option
	present in args is mapped to all of its arguments.		

]]--
function extract_options(args, options_table)
	local options = {}
	for i=1,#args do
		local option = args[i]
		local argc = options_table[option]
		if argc ~= nil then
			options[option] = {}
			for j=1,argc do
				table.insert(options[option],
				 args[i+j])
			end
		end
	end	
	return options
end


function print_bad_argument(error_msg)
	print("bad argument: " .. error_msg)
	os.exit(10)	
end


function process_options(args, options_table)
	local options = extract_options(args, options_table)
	local count = 0
	local delim = " "
	local cursor = 1
	local sel = -1
	for opt,optargs in pairs(options) do
		count = count+1+options_table[opt]
		if opt == "-h" then
			print(help)
			os.exit(0)
		end
		if opt == "-d" then
			delim = optargs[1]
			if delim == nil then
				print_bad_argument("DELIM must be defined")
			end
		end	
		if opt == "-c" then
			cursor = tonumber(optargs[1])
			if cursor == nil then
				print_bad_argument("CURS must be a number")
			end
		end
		if opt == "-s" then
			sel = tonumber(optargs[1])
			if sel == nil then
				print_bad_argument("SEL must be a number")
			end
		end
	end		
	return {count=count, cursor=cursor, delim=delim, sel=sel}
end


--[[
Name
	parse_str

Synopsis
	parse_str(str, delim)

Description
	This function has the objective to split the string str
	in substrings that are delimited by delim.

	The str argument is the targeted string to be splitted.
	
	The delim argument is an optional argument that specifies
	what to use as the delimiter, if no value is given the
	space character is used.

Return Value
	On success, this function returns an array, containing all
	substrings of str that ended in delim.

]]--
function parse_str(itens, str, delim)
	if delim == " " or delim == nil then
		delim = "%s"
	end
	for item in str:gmatch("[^"..delim.."]+") do
		table.insert(itens, item)
	end	
end


function find(table, item)
	for k,v in pairs(table) do
		if v == item then
			return k
		end
	end
	return nil
end


function dump_itens(navi, itens, selected)
	local dump = "\27[2J\27[H"
	for i=navi.scroll,navi.scroll+navi.rows-1 do
		if i > navi.max then
			break
		end
		if i == navi.cursor+navi.scroll-1 then
			dump = dump .. "\27[0;30;44m" .. itens[i] .. "\27[0m"
		elseif find(selected, itens[i]) ~= nil then
			dump = dump .. "\27[0;30;45m" .. itens[i] .. "\27[0m"
		else
			dump = dump .. itens[i]
		end
		if i < navi.scroll+navi.rows-1 then
			dump = dump .. "\n"
		end
	end
	return dump
end


function scroll_up(navi)
	if navi.scroll > 1 then
		navi.scroll = navi.scroll-1
	end	
end


function scroll_down(navi)
	if navi.scroll+navi.rows-1 < navi.max then
		navi.scroll = navi.scroll+1
	end
end


function move_cursor(direction, navi)
	local new_cursor = navi.cursor + direction
	local new_scroll = navi.scroll

	if new_cursor > navi.max then
		new_cursor = navi.max
	end
	
	if new_cursor < 1 then
		scroll_up(navi)
		new_cursor = 1
	elseif new_cursor > navi.rows then
		scroll_down(navi)
		new_cursor = navi.rows
	end
	navi.cursor = new_cursor
end


function get_itens_str(args, options_count)
	local not_opt = args[options_count+1]
	if not_opt ~= nil then
		for i=2,#args-options_count do
			not_opt = not_opt .. " " .. args[options_count+i]
		end
	end
	return not_opt
end


function get_itens(args, options)
	local itens = {}
	if #args == options.count then
		print("Usage: " .. args[0] .. " [-h] [-d DELIM] [-c CURS] ITENS")
		os.exit(1)
	end
	if options.delim == ' ' and #args-options.count > 1 then
		table.move(args, options.count+1, #args-options.count, 1, itens)
	else
		local itens_str = get_itens_str(args, options.count)
		parse_str(itens, itens_str, options.delim)
	end
	return itens
end

function toggle_selection(selected, itens, navi, max_selections)
	if max_selections == 0 then
		return
	end
	local item = itens[navi.cursor+navi.scroll-1] 
	local at = find(selected, item)
	if at == nil then
		if #selected == max_selections then
			table.remove(selected, 1)
		end
		table.insert(selected, item)
	else
		table.remove(selected, at)
	end
end


function create_navigator(cursor, scroll, rows, max)
	local navi = {cursor=cursor, scroll=scroll, rows=rows, max=max} 
	if navi.cursor < 1 then
		navi.cursor = 1
	elseif navi.cursor > max then
		navi.cursor = max
	end
	if navi.cursor > rows then
		navi.scroll = navi.cursor+1-rows
		navi.cursor = rows
	end
	return navi
end

local selected = {}
local options = process_options(arg, options_table)
local sel = options.sel
local itens = get_itens(arg, options)
local navigator = create_navigator(options.cursor, 1, dimensions[1], #itens)
local keymap = {
	["\t"] = {fun=toggle_selection, args={selected, itens, navigator, sel}},
	["J"] = {fun=scroll_down, args={navigator}},
	["K"] = {fun=scroll_up, args={navigator}},
	["j"] = {fun=move_cursor, args={1, navigator}},
	["k"] = {fun=move_cursor, args={-1, navigator}},
}
local screen = io.open("/dev/tty", "w")
if screen == nil then
	os.exit(2)
end

screen:write("\27[?25l") -- Make cursor invisible
luaterm.load_term(luaterm.get_fd(io.stdin))
luaterm.disable_canon(1, 0)

repeat
	local dump = dump_itens(navigator, itens, selected)
	screen:write(dump)
	screen:flush()
	local action = luaterm.raw_read()
	if keymap[action] == nil then
		goto continue
	end
	
	assert(keymap[action].fun, "mapped keys have to register a function")
	keymap[action].fun(table.unpack(keymap[action].args))
	::continue::
until action == '\n'
screen:write("\27[2J\27[H") -- Clear screen
screen:write("\27[?25h") -- Make cursor visible
screen:close()

luaterm.enable_canon()
luaterm.restore_term()

if #selected == 0 then
	print(itens[navigator.scroll+navigator.cursor-1])
else
	for _,v in ipairs(selected) do
		print(v)
	end
end
