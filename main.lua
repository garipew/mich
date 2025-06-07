#!/usr/bin/env lua

package.cpath = "./build/?.so;"..package.cpath

local luaterm = assert(require("luaterm"))

local isatty = assert(luaterm.isatty(luaterm.get_fd(io.stdin)) == 1,
		"mich must be run from a tty")

local hei,wid = luaterm.get_size()


help = [[
Name
	mich
Synopsis
	mich [-h] [-d DELIM] [itens]

Description
	The objective of this program is to present a minimal UI for
	the user to choose between different itens.

	If no item is given, rodion presents the content of cwd
	as options.

	The itens selected by the user are written to stdout.

	The name comes from Prince Michkin, the main character
	on the novel The Idiot.

Options
	-h - Displays this message.
	-d DELIM - Set the delimiter of the itens to DELIM.
                   The default value of DELIM used is the space
		   character.
	-s SEL - Define the start value of the cursor to SEL.
		 The default value of SEL is 1.
]]


options_table = {
	["-d"] = 1,
	["-h"] = 0,
	["-s"] = 1,
}


keymap = {
	["j"] = 1,
	["k"] = -1,
	["\t"] = 0,
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


function process_options(args, options_table)
	local options = extract_options(args, options_table)
	local count = 0
	local delim = " "
	local cursor = 1
	for opt,argvs in pairs(options) do
		count = count+1+options_table[opt]
		if opt == "-h" then
			print(help)
			os.exit(0)
		end
		if opt == "-d" then
			delim = argvs[1]
		end	
		if opt == "-s" then
			cursor = argvs[1]
		end
	end		
	return {count=count, cursor=cursor, delim=delim}
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
function parse_str(str, delim)
	if delim == " " or delim == nil then
		delim = "%s"
	end
	local itens = {}
	for item in str:gmatch("[^"..delim.."]+") do
		table.insert(itens, item)
	end	
	return itens
end


function find(table, item)
	for k,v in pairs(table) do
		if v == item then
			return k
		end
	end
	return nil
end


function display_itens(screen, itens, cursor, scroll, hei, selected)
	local clean = "\27[2J\27[H"
	for i=scroll,scroll+hei-1 do
		if i > #itens then
			break
		end
		local line = ""
		if i == scroll then
			line = line .. clean
		end
		if i == cursor+scroll-1 then
			line = line .. "\27[0;30;44m" .. itens[i] .. "\27[0m"
		elseif find(selected, itens[i]) ~= nil then
			line = line .. "\27[0;30;45m" .. itens[i] .. "\27[0m"
		else
			line = line .. itens[i]
		end
		if i ~= scroll+hei-1 then
			line = line .. "\n"
		end
		screen:write(line)
	end
	screen:flush()
end


function scroll_up(scroll)
	if scroll > 1 then
		return scroll-1
	end	
	return scroll
end


function scroll_down(scroll, hei, max)
	if scroll+hei-1 < max then
		return scroll+1
	end
	return scroll
end


function move_cursor(action, cursor, scroll, hei, max)
	local new_cursor = cursor + keymap[action]
	local new_scroll = scroll

	if new_cursor > max then
		new_cursor = max
	end
	
	if new_cursor < 1 then
		new_scroll = scroll_up(scroll)
		new_cursor = 1
	elseif new_cursor > hei then
		new_scroll = scroll_down(scroll, hei, max)
		new_cursor = hei
	end

	return new_cursor,new_scroll
end


function get_itens(args, options_count)
	local not_opt = arg[options_count+1]
	if not_opt ~= nil then
		for i=2,#arg-options_count do
			not_opt = not_opt .. " " .. arg[options_count+i]
		end
	end
	return not_opt
end


local scroll = 1
local cursor = 1
local selected = {}
local options = process_options(arg, options_table)
local itens_str = get_itens(arg, options.count)
if itens_str == nil then
	options.delim = " "
	itens_str = "wow no itens" 
end
local itens = parse_str(itens_str, options.delim)

local screen = io.open("/dev/tty", "w")
if screen == nil then
	os.exit()
end

luaterm.load_term(luaterm.get_fd(io.stdin))
luaterm.disable_canon(1, 0)

repeat
	display_itens(screen, itens, cursor, scroll, hei, selected)
	local action = luaterm.raw_read()
	if keymap[action] == nil then
		goto continue
	end

	if action == '\t' then
		local at = find(selected, itens[scroll+cursor-1])
		if at == nil then
			table.insert(selected, itens[scroll+cursor-1])
		else
			table.remove(selected, at)
		end
	else
		cursor,scroll = move_cursor(action, cursor, scroll, hei, #itens)
	end
	::continue::
until action == '\n'
screen:write("\27[2J\27[H")
screen:close()

luaterm.enable_canon()
luaterm.restore_term()

if #selected == 0 then
	print(itens[scroll+cursor-1])
else
	for _,v in ipairs(selected) do
		print(v)
	end
end
