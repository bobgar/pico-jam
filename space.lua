function spaceinit()

  _update = updatespace
  _draw = drawspace
  inittimeforseeds = stat(0)
  sectorsize = 512
  halfsectorsize = sectorsize/2
  location={x=0,y=0,sectorx=0,sectory=0}
  health = 3
  maxhealth = 3
  fuel = 3
  maxfuel = 3
  fuelburnrate = .0025
  food = 3
  maxfood = 3
  money=10
  hungerrate = .001
  vx=0
  vy=0
  vs=.3
  rs=.0025
  rd=0.95
  damp=0.95
  r=0
  rv=0
  --maxBullets = 5
  bullletttl = 150 --how many frames the bullet should live.  IE 30 * seconds (right now 5 seconds)
  bulletspeed = 2.0
  fireRate = 16
  timeSinceFire = 0
  bullets={}
  asteroids={}
  enemies={}
  sinr = 0
  cosr = 0
  stars = {}  
  curinteractible = nil
  for i=0, 500 do
    stars[i] = {x=rndi(sectorsize),y=rndi(sectorsize)}
  end
  relics={}
  relicactivated=false
  --relicactivated=true
  for i=1, 4 do
    --relics are in sectors at random direction on unit circle scaled by distance
    r = rnd()
    d = rnd()*5+10
    if i==1 then s = 132 end
    if i==2 then s = 133 end
    if i==3 then s = 148 end
    if i==4 then s = 149 end
    relics[i] = {x=flr( sin(r)*d), y=flr(cos(r)*d), found=false, sprite=s, type="relic"}
  end

  --relics[1].x = 1
  --relics[1].y = 1

  r = rnd()
  d = rnd()*10+20
  anomaly = {x=flr( sin(r)*d), y=flr(cos(r)*d)}
  --anomaly = {x=3, y=-3}
  changeSectors()
end


function getmaxcursor(interactible)
  count=0
  if interactible.rumor != nil then count+=1 end
  count += #interactible.shop
  return count
end

function updatespace()
  if interactcooldown > 0 then interactcooldown-=1 end
  if (btn(⬅️)) then rv-=rs end
  if (btn(➡️)) then rv+=rs end
  if (btn(⬆️) and fuel >= 0) then vy-=cos(r)*vs vx-=sin(r)*vs fuel -= fuelburnrate end
  if (btn(⬇️) and fuel >= 0) then vy+=cos(r)*vs vx+=sin(r)*vs fuel -= fuelburnrate end
  if (ibtn(❎) and curinteractible != nil) then
    if curinteractible.type == "planet" then
      _update=updateplanet
      _draw=drawplanet
      lastsaid="hello"
      cursorloc=0
      maxcursorloc = getmaxcursor(curinteractible)
      return
    elseif curinteractible.type == "relic" then
      curinteractible.found = true
      local allfound = true
      for r in all(relics) do
        if not r.found then allfound = false end
      end
      if allfound then relicactivated = true end
    elseif curinteractible.type == "asteroid" then
      money += curinteractible.value
      curinteractible.value = 0
      curinteractible.sprite = 98
    end
  end
  curinteractible = nil
  r+=rv
  rv*=rd
  location.x+=vx
  location.y+=vy
  vx*=damp
  vy*=damp
  timeSinceFire+=1  
  if(btn(🅾️)) and timeSinceFire > fireRate then -- and #bullets < maxBullets 
    spawnplayerbullet()
  end

  updatebullets()

  if location.x < 0 then
    location.sectorx-=1
    location.x += sectorsize
    changeSectors()
  end
  if location.y < 0 then
    location.sectory-=1
    location.y += sectorsize
    changeSectors()
  end
  if location.x >sectorsize then
    location.sectorx+=1
    location.x -= sectorsize
    changeSectors()
  end
  if location.y > sectorsize then
    location.sectory+=1
    location.y -= sectorsize
    changeSectors()
  end

  food-=hungerrate
  if food <=0 then
    gameoverscreeninit()
    return
  end

  if #asteroids < 10 and rnd() < .05 then spawnasteroid() end
  updateasteroids()

  if #enemies < 3 and rnd() < .0005 * sqrt(vecmag(location.sectorx, location.sectory)) then spawnenemy() end
  updateenemies()
end

function spawnenemybullet(e)
    local bvx = -sin(e.r)*e.bulletspeed
    local bvy = -cos(e.r)*e.bulletspeed
    add(bullets,{x=e.x+bvx*2,y=e.y+bvy*2,vx=bvx+e.vx,vy=bvy+e.vy, r=atan2(-bvy,-bvx), 
    sx=e.sx,sy=e.sy, ttl=bullletttl,
    team="enemy",sprite=142})
end

function spawnplayerbullet()
    timeSinceFire = 0
    local bvx = -sin(r)*bulletspeed
    local bvy = -cos(r)*bulletspeed
    add(bullets,{x=location.x+64+bvx*2,y=location.y+64+bvy*2,vx=bvx+vx,vy=bvy+vy, r=atan2(-bvy,-bvx), 
    sx=location.sectorx,sy=location.sectory, ttl=bullletttl,
    team="player",sprite=16})
    
end

function moveincludingsectors(o)
    o.x += o.vx
    if o.x < 0 then o.x += sectorsize o.sx -= 1 end
    if o.x > sectorsize then o.x -= sectorsize o.sx += 1 end
    o.y += o.vy
    if o.y < 0 then o.y += sectorsize o.sy -= 1 end
    if o.y > sectorsize then o.y -= sectorsize o.sy += 1 end    
end

function updatebullets()

  local bullettoremove = {}
  local enemytoremove = {}
  for b in all( bullets ) do
    moveincludingsectors(b)

    b.ttl -= 1
    if b.ttl <= 0 then add(bullettoremove, b) end

    if abs(b.sx - location.sectorx) + abs(b.sy - location.sectory) >= 3 then add(bullettoremove, b) end

    if b.team == "player" then
      for e in all(enemies) do
        --For bullets we assume they're in the same sector
        --it wouldn't be hard to translate them into the same sector for vec comparison, 
        --but I think this is good enough
        if e.sx == b.sx and e.sy == b.sy then
          local mag = vecmag(b.x-e.x, b.y-e.y)
          if mag < 12 then
            add(bullettoremove, b)
            e.health -= 1
            if e.health <= 0 then
              add(enemytoremove, e)
            end
          end
        end
      end
    end

    if b.team == "enemy" then
      local x = b.x - location.x + (b.sx - location.sectorx) * sectorsize
      local y = b.y - location.y + (b.sy - location.sectory) * sectorsize
      mag = vecmag(64 - x, 64 - y)
      if mag < 8 then 
        add(bullettoremove, b)
        health -= 1
        if health <= 0 then
          gameoverscreeninit()
        end
      end
    end
  end
  for e in all(enemytoremove) do
    del(enemies, e)
  end  
  for b in all(bullettoremove) do
    del(bullets, b)
  end  
end

function drawbullets()

  for b in all( bullets ) do
    local x = b.x - location.x + (b.sx - location.sectorx) * sectorsize
    local y = b.y - location.y + (b.sy - location.sectory) * sectorsize
    local sid = sslocfromid(b.sprite)
    rspr(sid.x,sid.y,x-4,y-4,b.r,1)
  end
end

function spawnenemy() 
  local r = rnd()
  local x = location.x+64 + sin(r) * 200
  local y = location.y+64 + cos(r) * 200
  local sprite = 140  
  add(enemies, {x=x,y=y,r=r,vx=rnd()*2-1, vy=rnd()*2-1, rv=rnd()*.01, r=r,
  sx=location.sectorx, sy=location.sectory, type="enemy", name="bandit",
  sprite=sprite, health=1, 
  timesincefire=0, firerate=30, bulletspeed=bulletspeed,
  damp=.9, accel=.15
})
end

function spawnguardian(x,y) 
  local r = rnd()
  local x = sectorsize / 2
  local y = sectorsize / 2
  local sprite = 138  
  add(enemies, {x=x,y=y,r=r,vx=rnd()*2-1, vy=rnd()*2-1, rv=rnd()*.01, r=r,
  sx=location.sectorx, sy=location.sectory, type="enemy", name="guardian",
  sprite=sprite, health=3, 
  timesincefire=0, firerate=30, bulletspeed=bulletspeed*1.5,
  damp=.9, accel=.075
})
end

function activeguardians()
  local c = 0
  for e in all(enemies) do
    if e.name == "guardian" then c+=1 end
  end
  return c
end

function updateenemies()
  local toremove = {}
  for e in all(enemies) do
    --TODO make them fly towards and shoot at the player
    local x = -(e.x - location.x + (e.sx - location.sectorx) * sectorsize -64)
    local y = -(e.y - location.y + (e.sy - location.sectory) * sectorsize -64)
    local m = vecmag(x, y)
    
    e.timesincefire+=1
    if m < 64 and e.timesincefire >= e.firerate then
      e.timesincefire = 0
      spawnenemybullet(e)
    end

    if m > 48 then
      e.vx += (x/m)*e.accel
      e.vy += (y/m)*e.accel
      e.r = atan2(-e.vy, -e.vx)
    else
      e.r = atan2(-y/m, -x/m)
    end

    moveincludingsectors(e)
    if abs(e.sx - location.sectorx) + abs(e.sy - location.sectory) >= 3 then add(toremove, e) end
    e.vx *= e.damp
    e.vy *= e.damp
  end

  for e in all(toremove) do
    printh("enemy removed")
    del(enemies, e)
  end
end

function drawenemies()    
  for e in all(enemies) do
    local x = e.x - location.x + (e.sx - location.sectorx) * sectorsize
    local y = e.y - location.y + (e.sy - location.sectory) * sectorsize
    
    --local r = atan2(y-64, x-64)
    

    if x>=-32 and x<160 and y>=-32 and y<160 then
      local sid = sslocfromid(e.sprite)
      rspr(sid.x,sid.y,x-8,y-8,e.r,2)
    end    
  end
end

function spawnasteroid()
  printh("asteroid spawned")  
  local r = rnd()
  local x = location.x+64 + sin(r) * 200
  local y = location.y+64 + cos(r) * 200
  local value = rndi(3)
  local sprite = 64
  if value == 2 then sprite = 66 elseif value == 3 then sprite = 96 end
  add(asteroids, {x=x,y=y,r=r,vx=rnd()*2-1, vy=rnd()*2-1, rv=rnd()*.01, sx=location.sectorx, sy=location.sectory, type="asteroid", value=value, sprite=sprite})
end

function updateasteroids()
  local toremove = {}
  for a in all(asteroids) do
    a.r += a.rv
    moveincludingsectors(a)    
    if abs(a.sx - location.sectorx) + abs(a.sy - location.sectory) >= 3 then add(toremove, a) end
  end

  for a in all(toremove) do
    printh("asteroid removed")
    del(asteroids, a)
  end
end

function drawasteroids()
  for a in all(asteroids) do
    local x = a.x - location.x + (a.sx - location.sectorx) * sectorsize
    local y = a.y - location.y + (a.sy - location.sectory) * sectorsize
    
    if x>=-32 and x<160 and y>=-32 and y<160 then
      local sid = sslocfromid(a.sprite)
      rspr(sid.x,sid.y,x-8,y-8,a.r,2)
      mag = vecmag(64 - x, 64 - y)
      if mag < 16 and a.value > 0 then 
        curinteractible = a
        rspr(32,80,x-8,y-8,a.r,2)
      end
    end
    
  end
end


function drawspace()  
  cls()
  drawstars()
  drawplanets()
  drawrelic()
  drawenemies()
  drawasteroids()

  --draw ship
  rspr(8,0,64-8,64-8,r,2)
  
  --if activated draw relic
  drawrelicactivated()
  --print('sx= ' .. location.sectorx .. '  sy= ' .. location.sectory)
  drawbullets()
  drawui()  
  if debug then
    drawdebugui()
  end
end

function  drawrelicactivated()
  if relicactivated then --and (anomaly.x != location.sectorx or anomaly.y != location.sectory) then
    dirx = (anomaly.x+.5) - (location.sectorx + location.x / sectorsize)
    diry = (anomaly.y+.5) - (location.sectory + location.y / sectorsize)
    mag = vecmag(dirx,diry)
    if mag > .15 then
      dirx = dirx/mag
      diry = diry/mag 
      ar = atan2(-diry,-dirx)
      rspr(48,64,64-8+ dirx * 24,64-8 + diry * 24,ar,2)
    end
    if (anomaly.x == location.sectorx and anomaly.y == location.sectory) then
      local x = sectorsize/2.0 - location.x + 32
      local y = sectorsize/2.0 - location.y + 32
      local loc = sslocfromid(136)
      sspr(loc.x, loc.y,16,16,x-16, y-16, 32,32)
      --if debug then pset(x,y,14) end
      mag = vecmag(64 - x, 64 - y)
      --if x >= 40 and x <= 72 and y >= 40 and y<=72 then
      print(mag, 0,100)
      if mag < 24 then
        --printh("You win")
        sspr(loc.x, loc.y,16,16,x-20, y-20, 40,40)
        _update = winscreenupdate
        _draw = winscreendraw
        winscreeninit()
      end
    end
  end
end

function drawrelic()
  for r in all(relics) do
    if not r.found and r.x == location.sectorx and r.y == location.sectory then                  
      x = sectorsize/2 - 16 - location.x
      y = sectorsize/2 - 16 - location.y
      
      --if x >= 40 and x <= 72 and y >= 40 and y<=72 then
      mag = vecmag(64 - x, 64 - y)
      if mag < 24 then
        local loc = sslocfromid(r.sprite+2)
        curinteractible = r
        sspr(loc.x, loc.y,8,8,x-16, y-16, 32,32)
      else
        local loc = sslocfromid(r.sprite)
        sspr(loc.x, loc.y,8,8,x-16, y-16, 32,32)
      end

      --if debug then pset(x,y,14) end
      --spr(r.sprite, sectorsize/2 - 4 - location.x, sectorsize/2 - 4 - location.y)
    end
  end
end


--TODO this is aweful and requires a better approach but works for now
function drawstars()
  for s in all(stars) do    
    x = s.x - location.x
    y = s.y - location.y
    if y < -halfsectorsize then y += sectorsize end
    if x < -halfsectorsize then x += sectorsize end
    if y > halfsectorsize then y -= sectorsize end
    if x > halfsectorsize then x -= sectorsize end
    if x>=0 and x<128 and y>=0 and y<128 then
      pset(x,y,10)
    end
  end
end

function drawplanets()
  i=0
  for p in all(planets) do
    x = p.x - location.x
    y = p.y - location.y
    if x>=-32 and x<160 and y>=-32 and y<160 then
      
      sspr(-8 + p.planettype*32,0,32,32,x-16,y-16) 
      mag = vecmag(64 - x, 64 - y)
      if mag < 24 then 
        curinteractible = p
        sspr(0,64,32,32,x-16,y-16)        
      end
      --if debug then pset(x,y,14) end
    end
    i+=1
  end
end


function changeSectors()
  planets = {}
  i=0
  for dx= -1 , 1, 1 do
    for dy= -1 , 1, 1 do
      --print(dx .. ',' .. dy,32+dx*24,32+dy*24)
      addplanetsforsector(dx,dy)      
    end
  end

  for r in all(relics) do
    if not r.found and r.x == location.sectorx and r.y == location.sectory then 
      if activeguardians() == 0 then
        spawnguardian()
      end
    end
  end
end

function dbgprintplanetcounts()
  for i=-25,25 do
    srand(sx * 113 + sy * 17 + inittimeforseeds)
    printh(flr(rnd() * (1/ (.2 * sd+1)) * 10))
  end
end

function addplanetsforsector(dsx,dsy)
  sx = location.sectorx+dsx
  sy = location.sectory+dsy
  sd = abs(sx) + abs(sy)
  srand(sx * 113 + sy * 17 + inittimeforseeds)
  --generate at most 4 planets
  planetcount = flr(rnd() * (1/ (.2 * sd+1)) * 10)
  for j=0 , planetcount do
    planettype = rndi(3)
    planets[i] = {x= rnd(sectorsize)+dsx*sectorsize, y=rnd(sectorsize)+dsy*sectorsize, type="planet",  planettype=planettype, shop={} }
    if(planettype == 1) then
      planets[i]['shop'][1] = {type="food", cost=rndi(3)}
      planets[i]['shop'][2] = {type="fuel", cost=rndi(3)}
      planets[i]['shop'][3] = {type="health", cost=rndi(3)}
    elseif(planettype == 2) then
      if rnd() < .25 then planets[i]['rumor'] = rndi(#relics) end
      planets[i]['shop'] = addshopitems({{prob=0.5, item={type="fuel", cost=rndi(3)}}, 
      {prob=0.5, item={type="fuelupgrade", cost=rndi(3)+2}}, 
      {prob=0.5, item={type="foodupgrade", cost=rndi(3)+2}}})
      --planets[i]['shop'][1] = {type="fuel", cost=1}
    elseif(planettype == 3) then
      if rnd() < .75 then planets[i]['rumor'] = rndi(#relics) end
      planets[i]['shop'] = addshopitems(
        {{prob=0.5, item={type="health", cost=rndi(3)}}, 
        {prob=0.5, item={type="fuelupgrade", cost=rndi(3)+2}},
         {prob=0.5, item={type="healthupgrade", cost=rndi(3)+2}}})
    end
    i+=1
  end
end

function addshopitems(itemprobtable)
  local shop={}
  local k = 0
  
  for sp in all(itemprobtable) do
    if rnd() < sp.prob then shop[k] = sp.item k+=1 end
  end

  return shop
end

function rndi(limit)
  return 1+flr(rnd(limit))
end 