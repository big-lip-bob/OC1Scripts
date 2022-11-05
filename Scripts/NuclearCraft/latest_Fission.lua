local component = require("component")
local event = require("event")
local graph = require("bobs_graph")

if not component.isAvailable("nc_fission_reactor") then
  print("Reactor not connected. Please connect the computer to the fission reactor.")
  return
end

local floor,sleep = math.floor,os.sleep
local r = component.nc_fission_reactor
local mr, mh 

local gpu = component.gpu
if gpu.maxResolution() > 40
 then gpu.setResolution(40,20)
 else print("You need a Tier 2 Screen Minimum") return
end

local heat,workV,autoV = false,true,false

local function summonHeat()

 if r.getReactorProcessHeat() > 0 then
  graph.drawBox(36,2,3,18,{0xffffff,0x777777,0xffcc00,0x555555}," ")
  heat = true
 end

end

local function reinitialize()
 
 r.deactivate()
 r.forceUpdate()
 
 hfl, hhl, rfl, rhl = 0, 0, 0, 0
 heat,workV,autoV = false,true,false

 gpu.setBackground(0x777777)
 gpu.fill(1,1,40,20," ")

 graph.drawBox(2,2,3,18,{0xffffff,0x777777,0xff0000,0x555555}," ")
 
 summonHeat()

 local L = {
 "Fuel :",
 "",
 "Efficiency :",
 "Heat Multi :",
 "Heat Gen :",
 "Heat :",
 "Energy :",
 "Energy Out :"
 }

 graph.text(6,3,L,0xeeaa00,0x777777) 

end

local function updateFuels()

 gpu.setForeground(0xeeaa00)
 gpu.setBackground(0x777777)
 gpu.set(14,3,r.getFissionFuelName())
 gpu.set(7,4,floor(r.getFissionFuelPower()) .. " RF/t - " .. floor(r.getFissionFuelHeat()) .. " H/t")
 
end



local function updateValues()

 mr, mh = r.getMaxEnergyStored(), r.getMaxHeatLevel()
 rf, ah = r.getEnergyStored(), r.getHeatLevel()
 
end

local hfl, hhl, rfl, rhl = 0, 0, 0, 0
local function updateGraph()
 rhl, rfl  = graph.drawVerticalGraph(rf,mr,3 ,3,1,16,rhl,rfl,0xee0000,0x555555)
 if heat then
  hhl, hfl = graph.drawVerticalGraph(ah,mh,37,3,1,16,hhl,hfl,0xeecc00,0x555555)
 end
end

local function updateM()

 local E = floor(r.getEfficiency() * 10) / 10
 local H = floor(r.getHeatMultiplier() * 10) / 10
 local HG,M = graph.addExponent(r.getReactorProcessHeat())

 gpu.setForeground(0xeeaa00)
 gpu.set(19,5,("%d%%\n%d%%\n%.1f %s H/t"):format(E, H, HG, M))
 
end

local abs = math.abs
local function updateMain()

 local H,HM   = graph.addExponent(ah)
 local MH,MHM = graph.addExponent(mh)
 local E,EM   = graph.addExponent(rf)
 local ME,MEH = graph.addExponent(mr)
  
 gpu.setBackground(0x777777)
 gpu.set(20,10,tostring(floor(abs(r.getEnergyChange()))))
 gpu.setForeground(0xeeaa00)
 gpu.set(15,8,("%.1f%s H / %.1f%s H\n%.1f%s RF / %.1f%s RF"):format(H,HM,M,MHM,E,EM,M,MEH))

end

local buttons = {}

local deactivate

local function activate()
 graph.makeButton(nil,22,12,12,3,"Activate",0xbb1111,0xffffff,true)
 sleep(0.2)
 buttons[2] = graph.makeButton(deactivate,22,12,12,3,"Deactivate",0xbb1111,0xffffff)
 r.activate()
end

deactivate = function() -- upvalue to not lose reference
 r.deactivate()
 graph.makeButton(nil,22,12,12,3,"Deactivate",0xbb1111,0xffffff,true)
 sleep(0.2)
 buttons[2] = graph.makeButton(activate,22,12,12,3,"Activate",0xbb1111,0xffffff)
end

local function autoButtonHolder () sleep(0.25) end
local function autoButton()
 if autoV then
  autoV = false
  graph.makeButton(nil,7,12,12,3,"Auto",0xbb1111,0xffffff,true)
  sleep(0.2)
  graph.makeButton(nil,7,12,12,3,"Auto",0xbb1111,0xffffff)
  buttons[2] = graph.makeButton(activate,22,12,12,3,"Activate",0xbb1111,0xffffff)
 else
  r.deactivate()
  autoV = true
  graph.makeButton(nil,7,12,12,3,"Auto",0x11bb11,0xffffff,true)
  sleep(0.2)
  graph.makeButton(nil,7,12,12,3,"Auto",0x11bb11,0xffffff)
  buttons[2] = graph.makeButton(autoButtonHolder,22,12,12,3,"Disabled",0x999999,0xeeeeee)
 end
end

local functions

local function updateAll()
 for i = 1,6 do
  functions[i]() sleep(0.1)
 end
end

local function buttonsDraw()

 buttons[1] = graph.makeButton(autoButton,7,12,12,3,"Auto",0xbb1111,0xffffff)
 buttons[2] = graph.makeButton(activate,22,12,12,3,"Activate",0xbb1111,0xffffff)
 buttons[3] = graph.makeButton(updateAll,22,16,12,3,"Update",0xbb1111,0xffffff)
 buttons[4] = graph.makeButton(function() workV = false end,7,16,12,3,"Exit",0x999999,0xeeeeee)
end

functions = { -- local upvalue
 updateValues,
 updateM,
 updateMain,
 updateFuels,
 buttonsDraw,
 updateGraph --6
}


reinitialize()
updateAll()

local MHP,WSEP = 35,75
while workV do

 updateValues()
 updateMain()
 updateGraph()

 local ev,ad,x,y = event.pull(1.5)
 
 if ev == "touch" then
  for i,t in ipairs(buttons)
   do if x >= t[1] and x <= t[3] and y >= t[2] and y <= t[4]
    then t[5]() break
   end
  end
 end
 
  if autoV then
 
  local SEP = rf / mr * 100
  local HP = ah / mh * 100

  if HP > MHP or SEP > WSEP
   then r.deactivate()
   else r.activate()
  end
  
 end

end

r.deactivate()
gpu.setBackground(0)
gpu.setForeground(0xffffff)
os.execute("clear")
print("Exiting")
