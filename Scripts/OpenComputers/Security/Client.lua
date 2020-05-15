local component = require("component")
local event = require("event")

if not component.isAvailable("modem") then return print("This program requires networking capabilities") end
local modem = component.modem

local args,opts = require("shell").parse(...)
local port = args[1] or 6969

local e_p = event.pull
-- syncer, be sure to have started the listener
modem.open(port)
local master
io.write("Sync Automatically (requires the server to be in pairing mode [y/n] : ")
if io.read():sub(1,1):lower() == "y" then
	modem.broadcast(port,"Im looking for ya")
	local _,_,_master = e_p(5,"modem_message")
	if not _master then print("failed syncing properly : timed out | Returning") return end
	master = _master
	print("Pairing succes")
else
	print("Enter Master Server Address (fully)")
	master = io.read()
end
os.sleep(1)


if not opts.r then
	local wa,ha = component.proxy(component.gpu.getScreen()).getAspectRatio()
	component.gpu.setResolution(20*wa,10*ha)
end

local term = require("term")
local read = term.read
local clear = term.clear
local succes_handler = loadfile("succ.lua") or (function() print("Succes Handler failed loading") return function() print("No loaded handler") end end)()

local error_count = 0
local function vararg_capture(event_name,receiver,sender,port,distance,...)
	print()
	if (...) == nil then
		print("Timed out")
		os.sleep(3)
		return
	else
		if (...) then
			print("Success")
			error_count = 0
			return succes_handler(...) -- yes a damn fucntion just for varargs even if i don't use really idk
		else
			print("Wrong password, retry")
			error_count = error_count + 1
			if error_count >= 5 then end 
			os.sleep(3)
		end
	end
end
while true do
	clear()
	print("Enter the password")
	local password = read({pwchar="*"})
	modem.send(master,port,password:sub(1,#password-1))
	vararg_capture(e_p(5,"modem_message"))
end