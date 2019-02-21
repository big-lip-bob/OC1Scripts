local component = require("component")
local event = require("event")
local thread = require("thread")
local graph = require("bobs_graph")

if not component.isAvailable("nc_fission_reactor") then
  print("Reactor not connected. Please connect the computer to the fission reactor.")
  os.exit()
end

local r = component.nc_fission_reactor

local gpu = component.gpu
if gpu.maxResolution() > 40
 then gpu.setResolution(40,20)
 else os.exit() print("You need a Tier 2 Screen Minimum")
end

gpu.setBackground(0x777777)
gpu.fill(1,1,40,20," ")

graph.DC(2,2,3,18,{0xffffff,0x777777,0xff0000,0x555555}," ")
graph.DC(36,2,3,18,{0xffffff,0x777777,0xffcc00,0x555555}," ")
 
 local L = {
 "" .. math.floor(r.getLengthX()) .. "x" .. math.floor(r.getLengthY()) .. "x" .. math.floor(r.getLengthZ()) .. " Fission Reactor" ,
 "Fuel :",
 "",
 "Efficiency :",
 "Heat :",
 "Energy :",
 "Energy I/O :",
 "Heat :",
 "Heat Gen :"
 }

graph.text(7,1,L,0xeeaa00,0x777777)

graph.TB(7,12,12,3,"Auto",0xbb1111,0xffffff)
graph.TB(22,12,12,3,"Update",0xbb1111,0xffffff)
graph.TB(7,16,12,3,"Exit",0x999999,0xeeeeee)

local mr, mh = r.getMaxEnergyStored(), r.getMaxHeatLevel()

local leaveV = false
function working() if not leaveV then return true end end
function leave() leaveV = true end
function auto() end

local t = thread.create(function()
  t:suspend()
  print("thread dead")
end)

local hfl, hhl, rfl, rhl = 0, 0, 0, 0

while working() do

rhl, rfl = graph.DGLV(r.getEnergyStored(),mr,3,3,1,17,rhl,rfl,0xee0000,0x555555)
hhl, hfl = graph.DGLV(r.getHeatLevel(),mh,37,3,1,17,hhl,hfl,0xeecc00,0x555555)

os.sleep(1)

end
