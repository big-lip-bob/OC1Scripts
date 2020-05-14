local redstone = require("component").redstone.setOutput

local side = require("sides")[(...)] or 1

redstone(side,15)
os.sleep(5)
redstone(side,0)