local component = require("component")
local event = require("event")

-- This script requires OC, Computronics and OpenSecurity to work

local noteblock = component.iron_noteblock
local pad = component.os_keypad
local door = component.os_doorcontroller

os.execute("resolution 40 50")
os.execute("clear")

function note(i,n,v) noteblock.playNote(i,n,v) end

local failmelody = {2,8,0.2,2,8,0.2,2,8,}
local melody = {0,18,0.10,0,18,0.20,0,20,0.20,0,23}

local input = ""
repeat
io.write("Set the PIN code, from 3 to 8 numbers : ")
input = io.read()
until tonumber(input) ~= nil and string.len(tostring(tonumber(input))) <= 8 and string.len(tostring(tonumber(input))) >= 3 

io.write("Set the Redstone IO component address : ")
red = io.read()

local length = string.len(tostring(tonumber(input)))
local password = tonumber(input)

local code = {}
for i = 1,length do
code[i] = "-" end
local k = 1

pad.setEventName("keypad")
pad.setShouldBeep(false)

function reset()
k = 1
for i = 1,length do
code[i] = "-" end
end

function fail(i)
if i == nil then
pad.setDisplay("Invalid")
reset()
print("Invalid Password")
else print("Unauthorized Redstone Access") end
local x = 1
door.close()
repeat
note(failmelody[x],failmelody[x+1],1)
os.sleep(failmelody[x+2])
x = x + 3
until failmelody[x+1] == nil
os.sleep(3)
end

function pass(i)
door.open()
if i == nil then
pad.setDisplay("Valid")
reset()
print("Valid Password")
else print("Authozied Redstone Access") end
local x = 1
repeat
note(melody[x],melody[x+1],1)
os.sleep(melody[x+2])
x = x + 3
until melody[x+1] == nil
os.sleep(3)
door.close()
end

while true do
print(table.concat(code)," ",password)
pad.setDisplay(table.concat(code))
comp,address,_,id = event.pullMultiple("keypad","redstone")
note(3,3,0.5)
if comp == "keypad" then
if tonumber(id) ~= nil then 
if k ~= length + 1 then k = k + 1 code[k-1] = tonumber(id) end
elseif id == "*" then 
if k ~= 1 then 
k = k - 1 code[k] = "-" 
end
elseif tonumber(table.concat(code)) == password then 
pass()
else 
fail()
end 
elseif address == red
then pass(1)
else fail(1)
end
end
