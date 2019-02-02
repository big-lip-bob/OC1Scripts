local component = require("component")
local term = require("term")
local thread = require("thread")

if not component.isAvailable("nc_fission_reactor") then
  print("Reactor not connected. Please connect the computer to the fission reactor.")
  os.exit()
end

function exit(msg)
term.clear()
print(msg)
os.exit()
end

t = thread.create(function()
  os.sleep(3)
  event.pull("key_")
  exit("Exiting due to a keyboard press")
end)

os.execute("resolution 48 24")

local reactor = component.nc_fission_reactor
local HP = 0
local SEP = 0
local MHP = 50
local WSEP = 75

while t:status() == "running" do

  	local SEP = reactor.getEnergyStored() / reactor.getMaxEnergyStored() * 100
	local HP = reactor.getHeatLevel() / reactor.getMaxHeatLevel() * 100
	
    if HP > MHP or SEP > WSEP
		then reactor.deactivate()
		else reactor.activate()
    end
	
  if term.isAvailable() then
		local E = (math.floor(reactor.getEfficiency() * 10)) / 10
		local H = (math.floor(reactor.getHeatMultiplier() * 10)) / 10
		
		local A
		if reactor.isProcessing == false
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
		"Energy I/O : " .. math.floor(-1 * (reactor.getEnergyChange())) ,
		"Heat :       " .. math.floor(reactor.getHeatLevel()) .. " / " .. math.floor(reactor.getMaxHeatLevel()) ,
		"Heat Gen :   " .. math.floor(reactor.getReactorProcessHeat())
		}
		
		term.clear()
		
		local LM = 3
		local S = 1
		
	for i, v in ipairs(L) do
      term.setCursor(LM , ( i * S ))
      term.write(v)
    end

  end
  
  os.sleep(0.05)
  
end

reactor.deactivate()
