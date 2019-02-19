
-- Bob's Secret stuff 打打打打打打打打打打

local component = require("component")
local gpu = component.gpu

local gcls = {[0]=" ","▂","▃","▄","▅","▆","▇","█"}
local ghl, pghl, gfl, pgfl = {}, {}, {}, {}

-- over complicated vertical line graph bar display 

local bobs = {}

function bobs.DGLV(input,maxx,x,y,w,h,k,t)

 if t == nil then
  t = glcs
 end

 local cc = #t
 local hper = input,maxx
 local preg = h * hper
 local gfl = math.floor(preg)
 local ghl = preg - gfl
 local sctd = math.floor(ghl * cc)
 
  if ghl ~= pghl then
 gpu.set(a,h-hgfl+1,t[sctd])
  if gfl ~= pgfl then
   gpu.fill(x,h-gfl+2,w,gfl,t[cc])
   gpu.fill(x,y,w,h-gfl-1," ")
  end
 end
 
 pghl[k], pgfl[k] = ghl[k], gfl[k]

end

-- color table, format : outer fore back , inner fore and back
-- ct = {0x115588,0xaabbdd,0x994466,0xffffee}
-- #t = 8 please

local bc = {"⢀","⣀","⡀","▐","⠈","⠉","⠁","▌"}

function bobs.DC(x,y,w,h,ct,f,t)

 local w,h = w-1,h-1

 if type(t) ~= "table" then
  t = bc
 end

 if ct ~= nil then
  if ct[3] and ct[4] then
   gpu.setForeground(ct[3])
   gpu.setBackground(ct[4])
  end
  if type(f) == "string" then
   if string.len(f) == 1 then
    gpu.fill(x+1,y+1,w-1,h-1,f)
   end
  end
  gpu.setForeground(ct[1])
  gpu.setBackground(ct[2])
 end

 gpu.set(x,y,t[1])
 gpu.set(x+w,y,t[3])
 gpu.set(x,y+h,t[5])
 gpu.set(x+w,y+h,t[7])
 gpu.fill(x+1,y,w-1,1,t[2])
 gpu.fill(x,y+1,1,h-1,t[4])
 gpu.fill(x+1,y+h,w-1,1,t[6])
 gpu.fill(x+w,y+1,1,h-1,t[8])

end

function bobs.text(x,y,tabletext,fore,back)
 
 if fore ~= nil then
  gpu.setForeground(fore)
 end
 if back ~= nil then
  gpu.setBackground(back)
 end
 
 for i,t in ipairs(tabletext) do
  gpu.set(x,y+i,t)
 end
 
end

-- ▄ ▀ █ ⣴ ⣠ ⠟ ⠋

function bobs.button(x,y,w,h,txt,clr,txtclr,anti,flat)

 local w,h = w-1,h-1
 if anti ~= nil then
  local mclr,pclr=clr-0x111111,clr+0x111111 else
  local mclr,pclr=clr+0x111111,clr-0x111111
 end
 
 if flat == nil or w > 3 and h > 3 then
  gpu.setBackground(clr-0x111111)
  gpu.setForeground(clr+0x111111)
  gpu.setBackground(clr+0x111111)
  gpu.setForeground(clr-0x111111)
  gpu.fill(x,y,w,h," ")
  gpu.fill(x+1,y+1,w,h,"█")
  gpu.set(x,y+h,"⣠")
  gpu.set(x+w,y,"⣴")
  gpu.setBackground(clr)
  gpu.fill(x+1,y+h,w-1,1,"▄")
  gpu.setForeground(clr+0x111111)
  gpu.fill(x+1,y,w-1,1,"▀")
  gpu.setBackground(clr)
  gpu.fill(x+1,y+1,w-1,h-1," ")
  else
  gpu.setBackground(clr)
  gpu.fill(x,y,w,h," ")
 end
 gpu.setForeground(txtclr)
 gpu.set(math.floor(x+w/2-string.len(txt)/2+0.5	),math.floor(y+h/2+0.5),txt) 
end

return bobs
