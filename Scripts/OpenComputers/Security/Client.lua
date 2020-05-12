local component = require("component")
local event = require("event")

if not component.isAvailable("modem") then return print("This program requires networking capabilities") end
local modem = component.modem

local args,opts = require("shell").parse(...)
local port = args[1] or 6969

local e_p = event.pull
-- syncer, be sure to have started the listener
modem.open(port)
print("press enter to sync, be sure the server is listening (start_listen)");io.read()
modem.broadcast(port,"Im looking for ya")
local _,_,master = e_p(5,"modem_message")
if not master then print("failed syncing properly : timed out") return end

print("Pairing succes")
os.sleep(3)
local clear = require("term").clear
local succes_handler = loadfile("succ.lua")
while true do
	clear()
	print("Enter the password")
	local password = io.read()
	if password ~= "" then
		modem.send(master,port,password)
		local _,_,_,_,_,result = e_p(5,"modem_message")
		if not _ then print("Time outd") else
			if result then
				print("Success")
				succes_handler()
			else
				print("Wrong password, retry")
			end
		end
	else
		print("nice try with that empty password")
	end
	os.sleep(3)
end