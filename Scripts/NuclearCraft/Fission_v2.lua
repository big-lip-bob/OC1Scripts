local component = require("component")
local event = require("event")
local thread = require("thread")

if not component.isAvailable("nc_fission_reactor") then
  print("Reactor not connected. Please connect the computer to the fission reactor.")
  os.exit()
end

local r = component.nc_fission_reactor

local gpu = component.gpu
if gpu.maxResolution() > 50
 then gpu.setResolution(48,24)
 else os.exit() print("You need a Tier 2 Screen Minimum")
end

-- gpu.setBackground(0xdd9900)
gpu.setBackground(0x777777)
gpu.setForeground(0xFFFFFF)
gpu.fill(1,1,48,24," ")
gpu.set(2,1,"⢀⣀⡀")
gpu.fill(2,2,1,22,"▐")
gpu.set(2,24,"⠈⠉⠁")
gpu.fill(4,2,1,22,"▌")
gpu.setBackground(0x555555)
gpu.setForeground(0xdd0000)
gpu.fill(3,2,1,22," ")
gpu.copy(2,1,3,24,4,0)

local gcls = {[0] = "","▂","▃","▄","▅","▆","▇","█"}
local cc = #gcls
local res = 22

while true do

 local rpghl,rpgfl,hpghl,hpgfl
 local rhper = r.getEnergyStored()/r.getMaxEnergyStored()
 local rpreg = res * rhper
 local rgfl = math.floor(rpreg)
 local rghl = rpreg - rgfl
 local rsctd = math.floor(rghl * cc)

 if rghl ~= rpghl then
 gpu.set(3,res-rgfl+1,gcls[rsctd])
  if rgfl ~= rpgfl then
   gpu.fill(3,res-rgfl+2,1,rgfl,gcls[cc])
   gpu.fill(3,2,1,res-rgfl-1," ")
  end
 end
 
 rpghl = rghl
 rpgfl = rgfl
 
 os.sleep(0.05)
 
 local hhper = r.getHeatLevel()/r.getMaxHeatLevel()
 local hpreg = res * hhper
 local hgfl = math.floor(hpreg)
 local hghl = hpreg - hgfl
 local hsctd = math.floor(hghl * cc)
 
  if hghl ~= hpghl then
 gpu.set(7,res-hgfl+1,gcls[hsctd])
  if hgfl ~= hpgfl then
   gpu.fill(7,res-hgfl+2,1,hgfl,gcls[cc])
   gpu.fill(7,2,1,res-hgfl-1," ")
  end
 end
 
 hpghl = hghl
 hpgfl = hgfl
 
 os.sleep(0.05)
 
end

--[[
▗▄▖ ▗▄▖
▐ ▌ ▐ ▌
▝▀▘ ▝▀▘
--]]
