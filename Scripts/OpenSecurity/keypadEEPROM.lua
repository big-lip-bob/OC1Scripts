local comp = component or require("component")
local get_comp = function(name) return comp.proxy(comp.list(name)()) end
local pc = computer or require("computer")

local pad = get_comp("os_keypad")
pad.setEventName("keypad") -- "keypad" "adress" id "char"
pad.setShouldBeep(false)

local glyphs,pages = {}
do
	local list = "ᚠᚡᚴᚵᚶᚢᚣᚤᚥᚨᚩᚪᚫᚬᚭᚮᚯᚰᚷᚸᚹᛉᛊᛋᚱᚦᚧᚺᚻᚽᚳᚾᛀᛁᚿᚼᛄᛅᛆᛇᛈᛠᛡᛢᛣᛐᛑᛏᛓᛒᛔᛕᛖᛗᛘᛦᛨᛩᛪ᛭ᛙᛚᛛᛜᛝᛞᛟᛤᛥᛮᛯᛰ"
	pages = math.ceil(#list/3/9) -- three bytes per glyph
	for char in list:gmatch("...") do
		glyphs[#glyphs+1] = char
	end
end

local function shuffle()
	for i = #glyphs, 1, -1 do
		local j = math.random(i)
		glyphs[i], glyphs[j] = glyphs[j], glyphs[i]
	end
end
shuffle()

local keypad_screen = {}

local set_display = pad.setDisplay
set_display("")
local function keypad_update()
	set_display(table.concat(keypad_screen))
end

local function keypad_add(c)
	local len = #keypad_screen
	if len >= 8 then
		return
	else
		keypad_screen[len+1] = c
	end
	keypad_update()
end

local play = function() end

local function keypad_rem()
	play("press")

	local len = #keypad_screen
	if len <= 0 then
		return
	else
		keypad_screen[len] = nil
	end
	keypad_update()
end

local set_key = pad.setKey

local page = 1
local function switch_pages(off)
	play("press")

	page = page + off
	if page > pages then page = 1 end
	if page < 1 then page = pages end
	local len = (page-1)*9

	for i = 1,9 do
		local glyph = glyphs[len+i]
		set_key(i,glyph)
	end
end

switch_pages(0)

local special = {r = "⮜  ",l = "⮞  ",v = "✔",x = "✖"} -- ,o = "◍"}
local functions = setmetatable({},{__index = function() play("press") return keypad_add end})

local password

local function sleep(timeout)
	local deadline = pc.uptime() + timeout
	repeat
		pc.pullSignal(deadline - pc.uptime())
	until pc.uptime() >= deadline
end

if comp.list("iron_noteblock")() then

	local failmelody = {2,8,.2,2,8,.2,2,8,0}
	local melody = {0,18,.10,0,18,.20,0,20,.20,0,23,0}
	local noteblock = get_comp("iron_noteblock")
	local note = noteblock.playNote
	play = function(z)
		local x = 1
		if z == "press" then
			note(3,3,.5)
		elseif z == "fail" then
			for x = 1,#failmelody,3 do
				note(failmelody[x],failmelody[x+1],1)
				sleep(failmelody[x+2])
			end
		elseif z == "pass" then
			for x = 1,#melody,3 do
				note(melody[x],melody[x+1],1)
				sleep(melody[x+2])
			end
		end
	end
end

local door = get_comp("os_doorcontroller")

local prev_page = function() switch_pages(-1) end
local next_page = function() switch_pages(1)  end

local check

local arrow = true
local function swapfunc()
	arrow = not arrow
	if arrow then
		set_key(10,special.r)
		set_key(12,special.l)
		functions[10] = prev_page
		functions[12] = next_page
	else
		set_key(10,special.x)
		set_key(12,special.v)
		functions[10] = keypad_rem
		functions[12] = check
	end
end
set_key(11,"◍")
functions[11] = function() play("press") swapfunc() end

swapfunc()

check = function() password = table.concat(keypad_screen) return true end

door.open()
set_display("Set Pass")
swapfunc()
while true do
	local event,a,b,c = pc.pullSignal()
	if event == "keypad" then
		if functions[b](c) then break end
	end
end
door.close()

local function clear_display()
	keypad_screen = {}
	keypad_update()
end
clear_display()

check = function()
	swapfunc()
	if table.concat(keypad_screen) == password then
		door.open()

		set_display("Valid")
		play("pass")
		sleep(1.7)

		door.close()
	else
		set_display("Wrong")
		play("fail")
	end
	clear_display()
end

swapfunc()

local address = comp.list("redstone")()
while true do
	local event,a,b,c = pc.pullSignal()
	if event == "keypad" then
		functions[b](c)
	elseif event == "redstone_changed" and a == address then
		door.open()

		clear_display()
		sleep(2)

		door.close()
	end	
end
