local function getPrimary(name) return component.proxy(component.list(name)()) end
local modem = getPrimary("modem") -- https://ocdoc.cil.li/component:modem
modem.open(4)
local drone = getPrimary("drone") -- https://ocdoc.cil.li/component:drone
local computer = computer
local chunkloader = getPrimary("chunkloader") -- https://ocdoc.cil.li/component:chunkloader
 
local maxVelocity = drone.getMaxVelocity()
local getEnergy = computer.energy
 
local getOffset,select,move,getVelocity,place,count = drone.getOffset,drone.select,drone.move,drone.getVelocity,drone.place,drone.count
 
local pull = computer.pullSignal
 
 
local function exit() computer.beep("---");computer.shutdown() end
 
local tntslot,buttonslot,fuelslot = 3,2,1
local tntpillarlenght = 1
local safe_height = 256
 
local generator = getPrimary("generator") --  https://ocdoc.cil.li/component:generator
local low_energy_threshold = computer.maxEnergy()-2400*.8 -- blaze rod burn time 2400 ticks : generator eff .8
local energy_consumption_per_sec = 3 -- 2.25e/s --w/ chunkloader no difference ho lee fuck -- went with 3 for safety -- more checks, less worries
 
local function checkEnergy()
  if getEnergy() < low_energy_threshold then
    select(fuelslot); generator.insert(1)
  end
end
 
local min = math.min
local function sleep_check(t)
  return pull(min(t or 1/0,getEnergy()/energy_consumption_per_sec))
end
 
--cx,cy,cz,master
local function bind()
  while true do
    local ev,self_addr,from,port,distance,bind_sign,x,y,z = sleep_check();checkEnergy()
    if ev == "modem_message" then
      if bind_sign == "__BIND" then
        return x,y,z,from
      else
        modem.send(from,4,"__BOMBER_READY",drone.name())
      end
    else
      checkEnergy()
    end
  end
end
 
local function get_target(master)
  while true do
    local ev,self_addr,from,port,distance,target_sign,x,z,who = sleep_check();checkEnergy()
    if ev == "modem_message" and from == master then
      if target_sign == "__GOTO" and who == drone.name() then
        return x,z
      else
        modem.send(from,4,"__BOMBER_READY",drone.name())
      end
    else
      checkEnergy()
    end
  end
end
 
local function go_ceiling(cy)
  move(0,safe_height-cy,0)
  local oldoffset,olderoffset
  repeat
    local offset = getOffset()
    sleep_check(offset/maxVelocity);checkEnergy()
    olderoffset = oldoffset
    oldoffset = offset
    if olderoffset == oldoffset then return false end -- stuck : fallback and die
  until offset < 1
  return true
end
 
 
local function go_to_xz(x,z)
  move(x,0,z) -- no way it fails or anything
  repeat
    local offset = getOffset()
    sleep_check(offset/maxVelocity);checkEnergy()
  until offset < 1
  sleep_check(1)
end
 
local function move_til_blocked()
  move(0,-safe_height,0)
  repeat
    sleep_check(1/maxVelocity);checkEnergy()
  until getVelocity() < .1
  local ty = getOffset()+.5
  move(0,ty,0)
  repeat
    local offset = getOffset()
    sleep_check(offset/maxVelocity);checkEnergy()
  until offset < 1
  sleep_check(1)
  return ty
end
 
local function place_tnt()
  select(tntslot)
  for i = 1,tntpillarlenght do
    move(0,1,0)
    sleep_check(1);checkEnergy()
    place(0) -- sides.down
  end
  select(buttonslot)
  move(0,1,0)
  sleep_check(1);checkEnergy()
  place(0) -- sides.down
  drone.use(0)
end
 
local function checkItems()
  return count(tntslot) >= tntpillarlenght or count(buttonslot) >= 1 or count(fuelslot) >= 64
end
 
if not checkItems() then exit() end
local bx,by,bz,master = bind()
getPrimary("chunkloader").setActive(true) -- chunkloading on
drone.setLightColor(0xFF0000)
while true do
  if not checkItems() then exit() end
  modem.broadcast(4,"__BOMBER_READY")
  local tx,tz = get_target(master)
  if not go_ceiling(by) then exit() end -- stuck
  go_to_xz(tx-bx,tz-bz)
  local ty = move_til_blocked()
  place_tnt()
  go_ceiling(ty+tntpillarlenght+1)
  go_to_xz(bx-tx,bz-tz)
  move(0,by-safe_height,0)
end
