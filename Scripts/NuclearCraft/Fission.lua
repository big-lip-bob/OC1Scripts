local component = require("component")
local term = require("term")
local event = require("event")

if not component.isAvailable("nc_fission_reactor") then
  print("Reactor not connected. Please connect the computer to the fission reactor.")
  os.exit()
end

local run = true

local x , y = component.gpu.maxResolution()
local x = math.min(y,24) * 2
component.gpu.setResolution(x,x/2)

local reactor = component.nc_fission_reactor

local E,H,C,G,HP,SEP,MPH,WSEP
local runv = true

function run(b)
 if b and runv then return true
  else runv = false
 end
end

function update()
 HP = 0
 SEP = 0
 MHP = 50
 WSEP = 75
 
 if term.isAvailable() then
  E = (math.floor(reactor.getEfficiency() * 10)) / 10
  H = (math.floor(reactor.getHeatMultiplier() * 10)) / 10
  C = math.floor(math.abs(reactor.getEnergyChange()))
  local preG = math.floor(reactor.getReactorProcessHeat())
  if preG > 0
   then G = preG
   else G = "None"
  end
 end
end

update()

  local A = ""
  if C > 0
   then A = "Active"
   else A = "Standby"
  end

local L = {
"" ,
"" .. math.floor(reactor.getLengthX()) .. "x" .. math.floor(reactor.getLengthY()) .. "x" .. math.floor(reactor.getLengthZ()) .. " " .. A .. " Fission Reactor" ,
"Fuel :       " .. reactor.getFissionFuelName() ,
"             " .. reactor.getFissionFuelPower() .. " RF/t - " .. reactor.getFissionFuelHeat() .. " H/t",
"Efficiency : " .. E .. "%" ,
"Heat :       " .. H .. "%" ,
"Energy :     " .. math.floor(reactor.getEnergyStored()) .. " / " .. math.floor(reactor.getMaxEnergyStored()) ,
"Energy I/O : " .. C ,
"Heat :       " .. math.floor(reactor.getHeatLevel()) .. " / " .. math.floor(reactor.getMaxHeatLevel()) ,
"Heat Gen :   " .. G,
}

local lent = #L

local Help = {
"",
"Press U to call an update to all the values",
"Press A to toggle Auto control : " .. tostring(auto),
"Press E to exit the script",
"Press H to toggle this help message"
}

while run(true) do

 local auto = false
 
 if auto == true then
  local SEP = reactor.getEnergyStored() / reactor.getMaxEnergyStored() * 100
  local HP = reactor.getHeatLevel() / reactor.getMaxHeatLevel() * 100
   if HP > MHP or SEP > WSEP
   then reactor.deactivate()
   else reactor.activate()
  end
 end
	
 if term.isAvailable() then
	
  local help = true

  term.clear()

  local LM = 3
		
  for i, v in ipairs(L) do
   term.setCursor(LM,i)
   term.write(v)
  end
   
  if help == true then
   for i,v in ipairs(Help) do
    term.setCursor(LM,lent+i)
    term.write(v)
   end
  end
  local function autof() if auto == true then auto = false else auto = true end end
  local function helpf() if help == true then help = false else help = true end end
  local event, addres , v1 , v2 = event.pull(0.3)
  local keyactions = {[35]=helpf,[30]=autof,[22]=update,[18]=run(false)}
  if event == "key_down" then if keyactions[v2] ~= nil then keyactions[v2]() end end
 else auto = true
 end
end

reactor.deactivate()
term.clear()
if component.isAvailable("gpu") then
component.gpu.setResolution(component.gpu.maxResolution())
end
