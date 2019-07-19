local component = require("component")
local event = require("event")
require("term").clear()

local gpu = component.gpu

component.screen.setTouchModeInverted(true)

local function rgb256(r,g,b)
 return r*256*256+g*256+b
end

local s = "  "
local set = gpu.set
local color = gpu.setBackground

local br,bc,sr,sc = 3,2,6,6
gpu.setResolution(2*br*sr,bc*sc)
local floor = math.floor

local function buildgrid(br,bc,sr,sc)
 local rcr,bcc,gcr = 255/sr,255/sc,255/bc
 local gcc = gcr/(br-1)
 for gyc = 0,bc-1 do
  for gxc = 0,br-1 do
   for rx = 0,sr-1 do
    for by = 0,sc-1 do
     color(rgb256(floor(rx*rcr),floor(gyc*gcr+gxc*gcc),floor(by*bcc)))
     set((gxc*sr+rx)*2+1,gyc*sc+by+1,s)
    end
   end
  end
 end
end

buildgrid(br,bc,sr,sc)
color(0)

local function rgb32(r,g,b)
 return r*32*32+g*32+b
end

local proxy = component.proxy
local rcr,bcc,gcr = 31/(sr-1),31/(sc-1),31/bc
local gcc = gcr/(br-1)
while true do

 local event,address,x,y,button,name = event.pull("touch")
 x = floor((x+1)/2)-1
 y = y - 1

 local lbr,lbc = x//sc,y//sr
 local lsr,lsc = x%sr,y%sc

 for address in pairs(component.list("colorful_lamp")) do
  proxy(address).setLampColor(rgb32(floor(lsr*rcr),floor(lbc*gcr+lbr*gcc),floor(lsc*bcc)))
 end

end