local args,opts = require("shell").parse(...)

local component = require("component")
local event = require("event")

if not component.isAvailable("modem") then return print("This program requires networking capabilities") end
local modem = component.modem

local g = _G

if not g._PMMaster then
	print("Welcome to ServerMaster, btw where's my factorio key :wink:")
	g._PMMaster = {
		config = {port = 6969},
		trusted_sources = {},
		allowed_passwords = {},
		default_stdout = io.stdout,
		commands = {
			init = function(manager)
				if manager.thread_id then -- Password Manager => PM
					manager.default_stdout:write("service already running \n")
				else
					manager.thread_id = event.listen("modem_message",function(event_name,receiver,sender,port,distance,...) -- event subscription
						if manager.trusted_sources[sender] then
							if manager.allowed_passwords[(...)] then
								manager.default_stdout:write(sender:sub(1,8).." entered a correct password : "..distance.." away \n")
								modem.send(sender,port,true,"Password is allowed") -- true to allow
							else
								modem.send(sender,port,false,"Rejected password") -- true to allow
								manager.default_stdout:write("Wrong password entered over "..sender:sub(1,8).." : "..distance.." away \n") -- you can have a file too
							end
						else
							manager.default_stdout:write("Outsider "..sender:sub(1,8).." tried accesing the service : "..distance.." away \n")
						end
					end)
				end
			end,
			passwords = function(manager,args)
				if #args > 1 then
					for i = 2,#args do manager.allowed_passwords[args[i]] = true end
				else
					manager.default_stdout:write("Registered passwords : \n")
					for k in pairs(manager.allowed_passwords) do manager.default_stdout:write(k," ") end
					manager.default_stdout:write("\n")
				end
			end,
			sources =   function(manager,args)
				if #args > 1 then
					for i = 2,#args do manager.trusted_sources[args[i]]   = true end
				else
					manager.default_stdout:write("Registered sources : \n")
					for k in pairs(manager.trusted_sources) do manager.default_stdout:write(k," ") end
					manager.default_stdout:write("\n")
				end
			end,
			remove_passwords = function(manager,args)
				for _,v in ipairs(args) do manager.allowed_passwords[v] = nil end
			end,
			remove_sources   = function(manager,args)
				for _,v in ipairs(args) do manager.trusted_sources[v] = nil end
			end,
			reset = function(manager)
				g._PMMaster = nil
				manager.commands.stop(manager)
			end,
			start_listen = function(manager)
				if manager.listener_id then
					manager.default_stdout:write("Listener for new connections already active \n")
				else 
					manager.commands.stop(manager)
					manager.listener_id = event.listen("modem_message",function(event_name,receiver,sender,port,distance,...) -- event subscription
						if manager.trusted_sources[sender] then
							manager.default_stdout:write(sender:sub(1,8).." already registered \n")
						else
							if not (...)=="Im looking for ya" then return end
							manager.trusted_sources[sender] = true
							modem.send(sender,port,true,"Received well")
							manager.default_stdout:write("Added "..sender:sub(1,8).." : "..distance.." away \n")
						end
					end)
				end
			end,
			stop_listen  = function(manager) if manager.listener_id then event.cancel(manager.listener_id) end end,
			stop = function(manager) if manager.thread_id then event.cancel(manager.thread_id) end end,
			shutdown = function(manager) manager.commands.stop(manager) manager.commands.stop_listen(manager) end,
		}
	}
	modem.open(g._PMMaster.config.port)
end
local master = g._PMMaster
master.commands.help = function(master) print("Available commands") for k in pairs(master.commands) do print(k) end end

(master.commands[args[1]] or master.commands["help"])(master,args,opts)

