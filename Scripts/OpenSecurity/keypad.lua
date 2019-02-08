local component = require("component")
local event = require("event")

os.execute("clear")
local pad,door

if component.isAvailable("os_keypad") and component.isAvailable("os_doorcontroller") then
pad = component.os_keypad
door = component.os_doorcontroller
else print("You need to connect a keypad and door controller from OpenSecurity to be able to use that script") goto END
end

pad.setEventName("keypad")

local input,noteblock,pass,fail

local x = 1
function play() end
function note() end

if component.isAvailable("iron_noteblock") then
failmelody = {2,8,0.2,2,8,0.2,2,8,}
passmelody = {0,18,0.10,0,18,0.20,0,20,0.20,0,23}
noteblock = component.iron_noteblock
pad.setShouldBeep(false)
function note(i,n,v) noteblock.playNote(i,n,v) end
function play(z)
repeat
note(z[x],z[x+1],1)
os.sleep(z[x+2])
x = x + 3
until z[x+1] == nil
end
else print("Connecting an Iron Noteblock from Computronics will add pass and fail melodies")
pad.setShouldBeep(true)
end

os.execute("resolution 40 50")

repeat
io.write("Set the PIN code, from 3 to 8 numbers : ")
input = io.read()
until tonumber(input) ~= nil and string.len(tostring(tonumber(input))) <= 8 and string.len(tostring(tonumber(input))) >= 3 

io.write("Set the Redstone IO component address : ")
red = io.read()

local length = string.len(tostring(tonumber(input)))
local password = tonumber(input)

local code = {}
function reset()
for i = 1,length do
code[i] = "-" end
end
reset()

function fail(i)
if i == nil then
pad.setDisplay("Invalid")
reset()
print("Invalid Password")
else print("Unauthorized Redstone Access") end
x = 1
door.close()
play(failmelody)
os.sleep(3)
end

function pass(i)
door.open()
if i == nil then
pad.setDisplay("Valid")
reset()
print("Valid Password")
else print("Authozied Redstone Access") end
x = 1
play(passmelody)
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
pass() k = 1
else 
fail() k = 1
end 
elseif address == red
then pass(1) k = 1
else fail(1) k = 1
end
end

::END::
