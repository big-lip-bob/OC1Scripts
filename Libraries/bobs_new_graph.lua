
-- Bob's Secret stuff 打打打打打打打打打打

local component = require("component")
local unicode = require("unicode")
local gpu = component.gpu
local gcls = {"▁","▂","▃","▄","▅","▆","▇","█",[0] = ""} -- Vertical bars for more controll

-- over complicated vertical line graph bar display 

local floor = math.floor

local bobs = {}

local gfill,gset = gpu.fill,gpu.set
function bobs.changeGPU(component)
	gpu = component
	gfill,gset = gpu.fill,gpu.set
end

function bobs.	(input,maxx,x,y,w,h,pghl,pgfl,fore,back)

	if fore and back then
		gsetBackground(back)
		gsetForeground(fore)
	end
	
	-- mathy stuff to make the bar graph and its subpixels
	local hper = input/maxx
	local preg = h * hper
	local gfl = floor(preg)
	local ghl = preg - gfl
	local sctd = floor(ghl * 6)

	-- check if the bar graph changed enough and needs a refresh
	if sctd ~= pghl then
		if gfl ~= pgfl then
			gfill(x,y+h-gfl,w,gfl,gcls[8])
			gfill(x,y,w,h-gfl," ") 
		end
		gfill(x,y+h-gfl-1,w,1,gcls[sctd])
	end
	
	return sctd,gfl -- those values need to be pumped back in the function as pghl and pgfl

end

-- color table, format : outer fore back , inner fore and back
-- ct = {0x115588,0xaabbdd,0x994466,0xffffee}
-- #t = 8 please

local bc = {"⢀","⣀","⡀","▐","⠈","⠉","⠁","▌"} -- Braille characters

function bobs.drawBox(x,y,w,h,ct,filler,t) -- self explanatory, to contain graph bars usually

	w,h = w-1,h-1
	
	t = t or bc -- user provided boundary characters cause why not 

	if ct then -- color table
		if ct[3] and ct[4] then
			gsetForeground(ct[3])
			gsetBackground(ct[4])
		end
		if filler then gfill(x+1,y+1,w-1,h-1,filler) end
		gsetForeground(ct[1])
		gsetBackground(ct[2])
	else
		if filler then gfill(x+1,y+1,w-1,h-1,filler) end 
	end
	
	--corners
	gset(x,y,t[1])
	gset(x+w,y,t[3])
	gset(x,y+h,t[5])
	gset(x+w,y+h,t[7])
	--edges
	gfill(x+1,y,w-1,1,t[2])
	gfill(x,y+1,1,h-1,t[4])
	gfill(x+1,y+h,w-1,1,t[6])
	gfill(x+w,y+1,1,h-1,t[8])

end

local concat = table.concat
function bobs.text(x,y,tabletext,fore,back,concatenation_filler) -- for drawing a table of text, if you hate new lines 
	if fore then gsetForeground(fore) end
	if back then gsetBackground(back) end	
	gset(x,y,concat(tabletext,concatenation_filler or "\n"))
end

-- ▄ ▀ █ ⣴ ⣠ ⠚ ⠟ ⠋ 打打打打打打打打打打

--[[ -- Buttons usage example
	local buttons = {}
	buttons[1] = graph.makeButton(autoButton,7,12,12,3,"Auto",0xbb1111,0xffffff)
	buttons[2] = graph.makeButton(updateAll,22,12,12,3,"Update",0xbb1111,0xffffff)
	buttons[3] = graph.makeButton((function() workV = false end),7,16,12,3,"Exit",0x999999,0xeeeeee)
	
	- - - - -
	
	event,address,x,y,player = event.pull()
	if event == "touch" then
		for i,t in ipairs(buttons)
			do if x >= t[1] and x <= t[3] and y >= t[2] and y <= t[4]
				then t[5]() break
			end
		end
	end
]]--

function bobs.makeButton(func,x,y,w,h,txt,clr,txtclr,anti,flat) -- self explanatory, makes a button and returns the new button data --can be combined with OOP

	local w,h = w-1,h-1 
	if anti then
		mclr,pclr=clr+0x111111,clr-0x111111 else
		mclr,pclr=clr-0x111111,clr+0x111111
	end
	
	if not flat and w+1 >= 3 and h+1 >= 3 then
		gsetBackground(pclr)
		gsetForeground(mclr)
		gfill(x,y,w,h," ")
		gfill(x+1,y+1,w,h,"█")
		gset(x,y+h,"⣠")
		gset(x+w,y,"⣴")
		gsetBackground(clr)
		gfill(x+1,y+h,w-1,1,"▄")
		gsetForeground(pclr)
		gfill(x+1,y,w-1,1,"▀")
		gsetBackground(clr)
		gfill(x+1,y+1,w-1,h-1," ")
		else
		gsetBackground(clr)
		gfill(x,y,w+1,h+1," ")
	end
	
	gsetBackground(clr)
	gsetForeground(txtclr)
	gset(floor(x+w/2-#txt/2+0.5	),floor(y+h/2+0.5),txt) 
	
	return {x,y,x+w,y+h,func}
	
end

-- 1 2 like 10100110 will give ⡣
-- 3 4 Please input a binary string / number
-- 5 6 打打打打打打打打打打
-- 7 8


local uchar,tostring,bytes = unicode.char,tostring,{1,8,2,16,4,32,64,128}
function bobs.braille(input) -- string / number

	local base = 0x2800
	local a,ac = {},0
	
	for c in tostring(input):gmatch(".") do ac = ac + 1;a[#a+1] = c end
	for i = 1,ac do if a[i] == "1" then base = base + bytes[i] end end
	return uchar(base)
	
end

function bobs.boxColor(x,y,w,h,f,b)

	gsetForeground(f)
	gsetBackground(b)
	gfill(x,y,w-1,h-1," ")
	
end

local log = math.log10 or math.log
function bobs.getIntLenght(number)

	if number <= 0 then
		return 0
	else
		return floor(log(number,10))
	end
	
end

function bobs.toInt(number) -- useless, use string:format
	if number % 1 == 0 then
		return floor(number)
	else
		return number
	end
end

local exponent = {"k","M","G","T","P","E","Z","Y",[0] = ""}
function bobs.addExponent(number)
	local base = floor(((bobs.getIntLenght(number)))/3)
	return number / 1000 ^ base, exponent[base]
end

function bobs.round(number,decimals,int)
	decimals = decimals or 0
	return floor((number * 10 ^ decimals) + int or 0.5) / 10 ^ decimals
	
end

function bobs.roundTo(number,maxlenght,flooring) -- redundant, to nuke
	return bobs.round(number,bobs.getIntLenght(number) - maxlenght,flooring or 0.5)
end

return bobs
