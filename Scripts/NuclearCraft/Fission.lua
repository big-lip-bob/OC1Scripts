local component = require("component")
local term = require("term")
local event = require("event")

if not component.isAvailable("nc_fission_reactor") then
  print("Reactor not connected. Please connect the computer to the fission reactor.")
  os.exit()
end

local run = true

os.execute("resolution 48 24")

local reactor = component.nc_fission_reactor
local HP = 0
local SEP = 0
local MHP = 50
local WSEP = 75
local E,H,C,G

if term.isAvailable() then
 E = (math.floor(reactor.getEfficiency() * 10)) / 10
 H = (math.floor(reactor.getHeatMultiplier() * 10)) / 10
 C = math.floor(math.abs(reactor.getEnergyChange()))
 local preG = math.floor(reactor.getReactorProcessHeat())
 G
 if preG > 0
 then G = preG
 else G = "None"
 end
end
	
while run do

 local SEP = reactor.getEnergyStored() / reactor.getMaxEnergyStored() * 100
 local HP = reactor.getHeatLevel() / reactor.getMaxHeatLevel() * 100
	
 if HP > MHP or SEP > WSEP
  then reactor.deactivate()
  else reactor.activate()
 end
	
 if term.isAvailable() then
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
  "Heat Gen :   " .. G
  }

  term.clear()

  local LM = 3
  local S = 1
		
  for i, v in ipairs(L) do
   term.setCursor(LM , ( i * S ))
   term.write(v)
   end
 end
  
 local event, addres , v1 , v2 = event.pull(0.25)
 if event == "key_down" then
  term.clear()
  print("Exiting due to keyboard press")
  break
 end 
end

reactor.deactivate()
