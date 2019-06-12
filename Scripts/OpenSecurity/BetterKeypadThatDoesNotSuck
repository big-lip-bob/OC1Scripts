local component = require("component")
local event = require("event")
local thread = require("thread")
-- "keypad" "adress" id "char"

local pad = component.os_keypad
pad.setEventName("keypad")
pad.setShouldBeep(false)

local glyphs = {"ᚠ","ᚡ","ᚴ","ᚵ","ᚶ","ᚢ","ᚣ","ᚤ","ᚥ","ᚨ","ᚩ","ᚪ","ᚫ","ᚬ","ᚭ","ᚮ","ᚯ","ᚰ","ᚷ","ᚸ","ᚹ","ᛉ","ᛊ","ᛋ","ᚱ","ᚦ","ᚧ","ᚺ","ᚻ","ᚽ","ᚳ","ᚾ","ᛀ","ᛁ","ᚿ","ᚼ","ᛄ","ᛅ","ᛆ","ᛇ","ᛈ","ᛠ","ᛡ","ᛢ","ᛣ","ᛐ","ᛑ","ᛏ","ᛓ","ᛒ","ᛔ","ᛕ","ᛖ","ᛗ","ᛘ","ᛦ","ᛨ","ᛩ","ᛪ","᛭","ᛙ","ᛚ","ᛛ","ᛜ","ᛝ","ᛞ","ᛟ","ᛤ","ᛥ","ᛮ","ᛯ","ᛰ"}
local pages = math.ceil(#glyphs/9)

--[[ NO UTF8 SUPPORT FUCKING REEEEee
do
 local list = "ᚠᚡᚴᚵᚶᚢᚣᚤᚥᚨᚩᚪᚫᚬᚭᚮᚯᚰᚷᚸᚹᛉᛊᛋᚱᚦᚧᚺᚻᚽᚳᚾᛀᛁᚿᚼᛄᛅᛆᛇᛈᛠᛡᛢᛣᛐᛑᛏᛓᛒᛔᛕᛖᛗᛘᛦᛨᛩᛪ᛭ᛙᛚᛛᛜᛝᛞᛟᛤᛥᛮᛯᛰ"
 pages = math.ceil(#list/9)
 for char in list:gmatch(".") do
  glyphs[#glyphs+1] = char
 end
end
]]	

local function shuffle()
 for i = #glyphs, 1, -1 do
  local j = math.random(i)
  glyphs[i], glyphs[j] = glyphs[j], glyphs[i]
 end
end
shuffle()

local screen = {}

local sd = pad.setDisplay
sd("")
local function ud()
 sd(table.concat(screen))
end

local function screenadd(c)
 local len = #screen
 if len >= 8 then
  return else
  screen[len+1] = c
 end
 ud()
end

local function screenrem()
 local len = #screen
 if len <= 0 then
  return else
  screen[len] = nil
 end
 ud()
end

local sk = pad.setKey

local page = 1
local function switchpages(off)
 page = page + off
 if page > pages then page = 1 end
 if page < 1 then page = pages end
 local len = (page-1)*9
 for i = 1,9 do
  local glyph = glyphs[len+i]
  sk(i,glyph)
 end
end
switchpages(0)
local play,spawfunc = function() end,function() end
local special = {r = "⮜  ",l = "⮞  ",v = "✔",x = "✖"} -- ,o = "◍"}
local functions = setmetatable({},{__index = function() play("press") return screenadd end})
local arrow = false
local function swapfunc()
 arrow = not arrow
 if arrow then
  sk(10,special.r)
  sk(12,special.l)
  functions[10] = function() play("press") switchpages(-1) end
  functions[12] = function() play("press") switchpages(1) end
 else
  sk(10,special.x)
  sk(12,special.v)
  functions[10] = function() play("press") screenrem() end
  functions[12] = function() screen = {} sd("Valid") swapfunc() play("pass") ud() end
 end
end
sk(11,"◍")
functions[11] = function() play("press") swapfunc() end
swapfunc()

local note,noteblock,failmelody,melody

if component.isAvailable("iron_noteblock") then

 failmelody = {2,8,0.2,2,8,0.2,2,8}
 melody = {0,18,0.10,0,18,0.20,0,20,0.20,0,23}
 noteblock = component.iron_noteblock
 note = function(i,n,v) noteblock.playNote(i,n,v) end
 play = function(z)
  local x = 1
  if z == "press" then
   note(3,3,0.5)
  elseif z == "fail" then repeat
   note(failmelody[x],failmelody[x+1],1)
   os.sleep(failmelody[x+2])
   x = x + 3
  until failmelody[x+1] == nil
  elseif z == "pass" then repeat
   note(melody[x],melody[x+1],1)
   os.sleep(melody[x+2])
   x = x + 3
  until melody[x+1] == nil
  end
 end
 
else
 print("Connecting an Iron Noteblock from Computronics will add pass and fail melodies") 
end

--[[thread.create(function()
 local circles,i = {"◴","◵","◶","◷"},0
 while true do
  i = i % 4 + 1
  sk(11,circles[i])
  os.sleep(1.5)
 end
end)]]

while true do
 local _,_,p,v = event.pull("keypad")
 functions[p](v)
end
