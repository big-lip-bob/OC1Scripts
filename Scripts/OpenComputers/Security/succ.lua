local redstone,side = require("component").redstone.setOutput,require("sides").up
redstone(side,15)
os.sleep(5)
redstone(side,0)