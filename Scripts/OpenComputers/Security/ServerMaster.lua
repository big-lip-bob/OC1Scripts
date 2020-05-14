local args,opts = require("shell").parse(...)



local g = _G

local current_ver = 0
if not g._PMMaster or g._PMMaster.version and g._PMMaster.version < current_ver then

	if require("computer").getArchitecture():find("J") then print("This program is meant for persistent architectures") end
	local event = require("event")

	g._PMMaster = {
		version = 0
		config = {port = 6969},
		trusted_sources = {},
		allowed_passwords = {},
		default_output = io.stdout,
		docs = {
			start = "Enables the listener",
			passwords = "Displays passwords, or adds them if arguments are provided, the -v option provides the default value the = less passwords take",
			sources = "Displays sources, or adds them if arguments are provided, to automatically pair, see pair",
			pair = "Starts pairing with a client",
			remove_passwords = "Removes passwords specified as arguments",
			remove_sources = "Removes sources specified as arguments",
			stop = "Disables the listener",
			open_port = "Changes and opens the port",
			reset = "Wipes the Manager from memory (No saves yet, using the fact that OC is persistent)",
			help = "Displays this ?",
			
		},
		commands = {
			open_port = function(manager,args)
				local old_port = manager.config.port
				manager.config.port = args[2] or manager.config.port
				if not component.isAvailable("modem") then return print("This program requires networking capabilities") end
				local modem = require("component").modem
				modem.close(old_port)
				modem.open(manager.config.port)
			end,
			start = function(manager)
				if manager.thread_id then -- Password Manager => PM
					manager.default_output:write("service already running \n")
				else
					manager.thread_id = event.listen("modem_message",function(event_name,receiver,sender,port,distance,...) -- event subscription
						if manager.trusted_sources[sender] then
							if manager.allowed_passwords[(...)] then
								manager.default_output:write(sender:sub(1,8).." entered a correct password : "..distance.." away \n")
								modem.send(sender,port,manager.allowed_passwords[(...)]) -- true to allow
							else
								modem.send(sender,port,false,"Rejected password") -- true to allow
								manager.default_output:write("Wrong password entered over "..sender:sub(1,8).." : "..distance.." away \n") -- you can have a file too
							end
						else
							manager.default_output:write("Outsider "..sender:sub(1,8).." tried accesing the service : "..distance.." away \n")
						end
					end)
				end
			end,
			passwords = function(manager,args,opts)
				local default = otps.v
				if #args > 1 then
					for i = 2,#args do
						local key,value = args[i]:match("([^=]*)=?(.*)")
						manager.allowed_passwords[key or args[i]] = value or default or true
					end
				else
					manager.default_output:write("Registered passwords : \n")
					for k,v in pairs(manager.allowed_passwords) do manager.default_output:write(k," ") if v ~= true then manager.default_output:write(" = ",v," ") end end
					manager.default_output:write("\n")
				end
			end,
			sources =   function(manager,args)
				if #args > 1 then
					for i = 2,#args do manager.trusted_sources[args[i]] = true end
				else
					manager.default_output:write("Registered sources : \n")
					for k in pairs(manager.trusted_sources) do manager.default_output:write(k," ") end
					manager.default_output:write("\n")
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
			pair = function(manager,args)
				local was_on = manager.commands.stop(manager)
				
				for _ = 1, tonumber(args[2]) or 1 do
					local event_name,receiver,sender,port,distance,... = event.pull("modem_message") -- event subscription
					if manager.trusted_sources[sender] then
						manager.default_output:write(sender:sub(1,8).." already registered \n")
					else
						if not (...)=="Im looking for ya" then return end
						manager.trusted_sources[sender] = true
						modem.send(sender,port,true,"Received well")
						manager.default_output:write("Added "..sender:sub(1,8).." : "..distance.." away \n")
					end
				end
				
				if was_on then manager.commands.start(manager) end
			end,
			stop = function(manager) if manager.thread_id then event.cancel(manager.thread_id) return ture end end,
			help = function(master) print("Available commands") for k in pairs(master.commands) do io.write(k," : ",manager.docs[k],"\n") end end
		}
	}
	g._PMMaster.commands.open_port(g._PMMaster)
end

local master = g._PMMaster
(master.commands[args[1]:lower()] or master.commands["help"])(master,args,opts)

