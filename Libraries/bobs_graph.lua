
-- Bob's Secret stuff 打打打打打打打打打打

local component = require("component")
local unicode = require("unicode")
local gpu = component.gpu
local gcls = {"▁","▂","▃","▄","▅","▆","▇","█",[0] = ""}

-- over complicated vertical line graph bar display 

local bobs = {}

function bobs.DGLV(input,maxx,x,y,w,h,pghl,pgfl,fore,back)

 if fore and back then
 gpu.setBackground(back)
 gpu.setForeground(fore)
 end

 local hper = input/maxx
 local preg = h * hper
 local gfl = math.floor(preg)
 local ghl = preg - gfl
 local sctd = math.floor(ghl * 6)

 if sctd ~= pghl then
  if gfl ~= pgfl then
   gpu.fill(x,y+h-gfl,w,gfl,gcls[8])
   gpu.fill(x,y,w,h-gfl," ") 
  end
  gpu.fill(x,y+h-gfl-1,w,1,gcls[sctd])
 end
 
 return sctd,gfl

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
  gpu.set(x+1,y-1+i,t)
 end
 
end

-- ▄ ▀ █ ⣴ ⣠ ⠚ ⠟ ⠋ 打打打打打打打打打打

--[[
 local buttons = {}
 buttons[1] = graph.TB(autoButton,7,12,12,3,"Auto",0xbb1111,0xffffff)
 buttons[2] = graph.TB(updateAll,22,12,12,3,"Update",0xbb1111,0xffffff)
 buttons[3] = graph.TB((function() workV = false end),7,16,12,3,"Exit",0x999999,0xeeeeee)

 event,address,x,y,player = event.pull()
 if event == "touch" then
  for i,t in ipairs(buttons)
   do if x >= t[1] and x <= t[3] and y >= t[2] and y <= t[4]
    then t[5]() break
   end
  end
 end
]]--

function bobs.TB(func,x,y,w,h,txt,clr,txtclr,anti,flat)

 local w,h = w-1,h-1 
 if anti  then
  mclr,pclr=clr+0x111111,clr-0x111111 else
  mclr,pclr=clr-0x111111,clr+0x111111
 end
 
 if not flat and w+1 >= 3 and h+1 >= 3 then
  gpu.setBackground(pclr)
  gpu.setForeground(mclr)
  gpu.fill(x,y,w,h," ")
  gpu.fill(x+1,y+1,w,h,"█")
  gpu.set(x,y+h,"⣠")
  gpu.set(x+w,y,"⣴")
  gpu.setBackground(clr)
  gpu.fill(x+1,y+h,w-1,1,"▄")
  gpu.setForeground(pclr)
  gpu.fill(x+1,y,w-1,1,"▀")
  gpu.setBackground(clr)
  gpu.fill(x+1,y+1,w-1,h-1," ")
  else
  gpu.setBackground(clr)
  gpu.fill(x,y,w+1,h+1," ")
 end
 
 gpu.setBackground(clr)
 gpu.setForeground(txtclr)
 gpu.set(math.floor(x+w/2-string.len(txt)/2+0.5	),math.floor(y+h/2+0.5),txt) 
 
 return {x,y,x+w,y+h,func}
 
end

-- 1 2 like 10100110 will give ⡣
-- 3 4 Please input a binary string
-- 5 6 打打打打打打打打打打
-- 7 8

function bobs.braille(input)

 local base = 0x2800
 local a,b = {},{1,8,2,16,4,32,64,128}
 
 for c in string.gmatch(tostring(input),".") do a[#a+1] = c end
 for i = 1,#a do if a[i] == "1" then base = base + b[i] end end
 return unicode.char(base)
 
end

function bobs.RCB(x,y,w,h,f,b)

 gpu.setForeground(f)
 gpu.setBackground(b)
 gpu.fill(x,y,w-1,h-1," ")
 
end

function bobs.GNL(number)

 if number <= 0 then
  return 0
 else
  return math.floor(math.log(number,10))
 end
 
end

function bobs.RSATC(number)

 local DS = number % 1

 if DS == 0 then
  return math.floor(number)
 else
  return number
 end

end

function bobs.EVC(number)

 local exponent = {"k","M","G","T","P","E","Z","Y",[0] = ""} --https://www.youtube.com/watch?v=lMJvDi0KNlM
 local base = math.floor(((bobs.GNL(number)))/3)
 return number / 1000 ^ base, exponent[base]

end

function bobs.round(number,decimals,int)

 if int == nil then int = 0.5 end
 local exponent = decimals or 0
 return math.floor((number * 10 ^ exponent) + int) / 10 ^ exponent
 
end

function bobs.RFSN(number,maxlenght,flooring)

 if not flooring
  then flooring = 0.5
 end 
 
 return bobs.round(number,bobs.GNL(number) - maxlenght,flooring)

end

return bobs











