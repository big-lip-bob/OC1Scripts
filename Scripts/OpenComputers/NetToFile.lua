local inet = require("internet")
local URL = ""
local body = ""
local filename= ""

io.write("Input the URL of the site : ")
URL = io.read()

local response = inet.request(URL)
for chunk in response do
  body = body .. chunk
end

print(body)

io.write("Do you want to write the output to a file ? If yes, enter file name : ")
filename = io.read()
local file =""
if filename ~= "" then
file = io.open(filename,"w")
file:write(body)
file:close()
end
