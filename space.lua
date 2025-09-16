function spaceinit()
  _update = updatespace
  _draw = drawspace
  inittimeforseeds = (stat(85)*0.001 + stat(84)*0.001*60 + stat(83)*0.001*60*60 + stat(82)*0.001*60*60*24) * stat(81)
  --dbgprintplanetcounts()
  sectorsize = 512
  halfsectorsize = sectorsize/2
  location={x=0,y=0,sectorx=0,sectory=0}
  if cheat then 
    health = 8
    maxhealth = 8
    fuel = 8
    maxfuel = 8
    food = 8
    maxfood = 8
    money = 50
  else
    health = 3
    maxhealth = 3
    fuel = 3
    maxfuel = 3
    food = 3
    maxfood = 3
    money = 5
  end
  caphealth=8
  capfuel=8
  capfood=8
  
  fuelburnrate = .0025
  hungerrate = .001
  vx=0
  vy=0
  vs=.3
  rs=.0025
  rd=0.9
  damp=0.95
  r=0
  rv=0
  bullletttl = 60 --how many frames the bullet should live.  IE 30 * seconds (right now 5 seconds)
  bulletspeed = 2.0
  fireRate = 16
  timeSinceFire = 0
  bullets={}
  asteroids={}
  enemies={}
  sinr = 0
  cosr = 0
  stars = {}  
  smk = {}
  exhaust = {}
  coins = {}
  damagedlastframe = false
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
    if cheat then if i<4 then relics[i].found = true end end
  end

  r = rnd()
  d = rnd()*10+20
  anomaly = {x=flr( sin(r)*d), y=flr(cos(r)*d)}

  
  if cheat then
    anomaly.x = 1
    anomaly.y = -1
    relics[4].x = 1
    relics[4].y = 1
  end 
  if fastmode then
    vs=2
    rs=.005
    bulletspeed = 4.0
    fireRate = 4
  end

  --anomaly = {x=3, y=-3}
  changeSectors()

  if mouseenabled then 
    shipsprite = 98
    playerbulletsprite = 15
    exhaustparticle = 47
  else 
    shipsprite = 1 
    playerbulletsprite = 16
    exhaustparticle = 31
  end
end


function getmaxcursor(interactible)
  count=0
  if interactible.rumor != nil then count+=1 end
  count += #interactible.shop
  return count
end

function updatespace()
  if btn(⬅️) then rv-=rs end
  if btn(➡️) then rv+=rs end
  if btn(⬆️) and fuel > 0 then 
    sfx(01)
    spawnexhaust(60,60,r,2,exhaustparticle)
    vy-=cos(r)*vs vx-=sin(r)*vs 
    fuel -= fuelburnrate 
    if fuel < 0 then fuel = 0 end 
  end
  if btn(⬇️) and fuel > 0 then 
    sfx(01)
    vy+=cos(r)*vs 
    vx+=sin(r)*vs 
    fuel -= fuelburnrate 
    if fuel < 0 then fuel = 0 end 
  end
  if btnp(❎) and curinteractible != nil then
    if curinteractible.type == "planet" then
      sfx(10)
      initplanet()
      lastsaid="hello"
      cursorloc=0
      maxcursorloc = getmaxcursor(curinteractible)
      return
    elseif curinteractible.type == "relic" then
      curinteractible.found = true
      local allfound = true
      sfx(02)
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
  --if #enemies < 3 and rnd() < .005 then spawnenemy() end
  updateenemies()
  updateexp()
  updatecoins()
  updateexhaust()
end

function spawnenemybullet(e)
  local r = e.r + rnd()*e.accuracy - e.accuracy/2.0
    local bvx = -sin(r)*e.bulletspeed
    local bvy = -cos(r)*e.bulletspeed
    add(bullets,{x=e.x+bvx*2,y=e.y+bvy*2,vx=bvx+e.vx,vy=bvy+e.vy, r=atan2(-bvy,-bvx), 
    sx=e.sx,sy=e.sy, ttl=bullletttl,
    team="enemy",sprite=e.bulletsprite})
end

function spawnplayerbullet()
  sfx(00)
    timeSinceFire = 0
    local bvx = -sin(r)*bulletspeed
    local bvy = -cos(r)*bulletspeed
    add(bullets,{x=location.x+64+bvx*2,y=location.y+64+bvy*2,vx=bvx+vx,vy=bvy+vy, r=atan2(-bvy,-bvx), 
    sx=location.sectorx,sy=location.sectory, ttl=bullletttl,
    team="player",sprite=playerbulletsprite})
    
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
          if mag < e.hitbox then
            add(bullettoremove, b)
            e.health -= 1
            if e.health <= 0 then
              add(enemytoremove, e)
              spawnexp(e.x,e.y,e.sx,e.sy)
              spawncoins(e.x,e.y,e.sx,e.sy,e.value)
              sfx(04)
            else
              sfx(05)
            end
          end
        end
      end

      for a in all(asteroids) do
        --For bullets we assume they're in the same sector
        --it wouldn't be hard to translate them into the same sector for vec comparison, 
        --but I think this is good enough
        if a.sx == b.sx and a.sy == b.sy then
          local mag = vecmag(b.x-a.x, b.y-a.y)
          if mag < 12 then
            add(bullettoremove, b)
            a.health -= 1
            if a.health <= 0 then
              del(asteroids, a)
              spawnexp(a.x,a.y,a.sx,a.sy)
              spawncoins(a.x,a.y,a.sx,a.sy,a.value)
              sfx(04)
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
        damageplayer(1)
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
  sprite=sprite, spritesize=2, health=1, value=rndi(5),
  timesincefire=0, firerate=30, bulletspeed=bulletspeed,bulletsprite=158,
  damp=.9, accel=.15,
  hitbox=12, firedistance=64, accuracy=.05, stopdistance=48
})
end

function spawnguardian(x,y) 
  local r = rnd()
  local sprite = 138  
  add(enemies, {x=x,y=y,r=r,vx=rnd()*2-1, vy=rnd()*2-1, rv=rnd()*.01, r=r,
  sx=location.sectorx, sy=location.sectory, type="enemy", name="guardian",
  sprite=sprite, spritesize=2, health=3, value=3,
  timesincefire=0, firerate=30, bulletspeed=bulletspeed*1.5, bulletsprite=142,
  damp=.9, accel=.075,
  hitbox=12, firedistance=64, accuracy=.05, stopdistance=48
})
end

function spawneye(x,y)
  local sprite = 196  
  add(enemies, {x=x,y=y,r=0,vx=0, vy=0, rv=.3,
  sx=anomaly.x, sy=anomaly.y, type="enemy", name="eye",
  sprite=sprite, spritesize=4, health=8, value=0,
  timesincefire=0, firerate=10, bulletspeed=bulletspeed*2.5, bulletsprite=143,
  damp=.9, accel=0,
  hitbox=20, firedistance=96, accuracy=.1, stopdistance=96
})
end

function activeenemytype(name)
  local c = 0
  for e in all(enemies) do
    if e.name == name then c+=1 end
  end
  return c
end

function updateenemies()
  for e in all(enemies) do
    local x = -(e.x - location.x + (e.sx - location.sectorx) * sectorsize -64)
    local y = -(e.y - location.y + (e.sy - location.sectory) * sectorsize -64)
    local m = vecmag(x, y)
    
    e.timesincefire+=1
    if m < e.firedistance and e.timesincefire >= e.firerate then
      e.timesincefire = 0
      spawnenemybullet(e)
      sfx(07)
    end

    if m > e.stopdistance then
      e.vx += (x/m)*e.accel
      e.vy += (y/m)*e.accel
      e.r = atan2(-e.vy, -e.vx)
    else
      e.r = atan2(-y/m, -x/m)
    end

    moveincludingsectors(e)    
    e.vx *= e.damp
    e.vy *= e.damp
    if abs(e.sx - location.sectorx) + abs(e.sy - location.sectory) >= 3 and e.name!="eye" then del(enemies, e) end
  end
end

function drawenemies()    
  for e in all(enemies) do
    local x = e.x - location.x + (e.sx - location.sectorx) * sectorsize
    local y = e.y - location.y + (e.sy - location.sectory) * sectorsize
    
    --local r = atan2(y-64, x-64)
    

    if x>=-32 and x<160 and y>=-32 and y<160 then
      local sid = sslocfromid(e.sprite)
      rspr(sid.x,sid.y,x-e.spritesize*4,y-e.spritesize*4,e.r,e.spritesize)
    end    
  end
end

function spawnasteroid()  
  local r = rnd()
  local x = location.x+64 + sin(r) * 200
  local y = location.y+64 + cos(r) * 200
  local value = rndi(3)
  local sprite = 64
  if value == 2 then sprite = 66 elseif value == 3 then sprite = 96 end
  add(asteroids, {x=x,y=y,r=r,vx=rnd()*2-1, vy=rnd()*2-1, rv=rnd()*.01, sx=location.sectorx, sy=location.sectory, type="asteroid", value=value, health=1, sprite=sprite})
end

function updateasteroids()
  for a in all(asteroids) do
    a.r += a.rv
    moveincludingsectors(a)    
    if abs(a.sx - location.sectorx) + abs(a.sy - location.sectory) >= 3 then del(asteroids, a)  end
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
        --curinteractible = a
        --rspr(32,80,x-8,y-8,a.r,2)
        damageplayer(1) 
        spawnexp(a.x,a.y,a.sx,a.sy)
        del(asteroids, a)
        sfx(04)
      end
    end
  end
end


function drawspace()  
  if damagedlastframe then
    cls(8)
    damagedlastframe = false
  else
    cls()
  end
  drawstars()
  drawplanets()
  drawrelic()
  drawenemies()
  drawasteroids()
  drawcoins()
  drawexp()
  drawexhaust()
  
  --draw ship
  local ss = sslocfromid(shipsprite)
  rspr(ss.x,ss.y,64-8,64-8,r,2)
  
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
    dirx = (anomaly.x+.45) - (location.sectorx + location.x / sectorsize)
    diry = (anomaly.y+.45) - (location.sectory + location.y / sectorsize)
    mag = vecmag(dirx,diry)
    if mag > .15 then
      dirx = dirx/mag
      diry = diry/mag 
      ar = atan2(-diry,-dirx)
      rspr(48,64,64-8+ dirx * 24,64-8 + diry * 24,ar,2)
    end
    if (anomaly.x == location.sectorx and anomaly.y == location.sectory) and activeenemytype("eye") == 0  then
      local x = sectorsize/2.0 - location.x
      local y = sectorsize/2.0 - location.y
      local loc = sslocfromid(136)
      sspr(loc.x, loc.y,16,16,x-16, y-16, 32,32)
      --if debug then pset(x,y,14) end
      mag = vecmag(64 - x, 64 - y)
      --if x >= 40 and x <= 72 and y >= 40 and y<=72 then
      --print(mag, 0,100)
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
      if activeenemytype("guardian") == 0 then
        spawnguardian(sectorsize / 2, sectorsize / 2)        
      end
    end
  end

  if anomaly.x == location.sectorx and anomaly.y == location.sectory then
    while activeenemytype("guardian") < 3 do
      spawnguardian(sectorsize / 2 + rnd() * 50 - 25, sectorsize / 2.0 + rnd() * 50 - 25)
      printh("spawning")
    end
    if activeenemytype("eye") == 0 then
      spawneye(sectorsize / 2 , sectorsize / 2)
    end
  end
end

function dbgprintplanetcounts()
  printh(inittimeforseeds)
  for i=-100,100, 10 do    
    srand(i * 113 + 0 * 17 + inittimeforseeds)
    printh("i = " .. i .. " planets = " .. flr((rnd()*.5+.5) * (1/ (.05 * abs(i) + 1)) * 10))
  end
end

function addplanetsforsector(dsx,dsy)
  local sx = location.sectorx+dsx
  local sy = location.sectory+dsy
  local sd = abs(sx) + abs(sy)
  srand(sx * 113 + sy * 17 + inittimeforseeds)
  --generate at most 10 planets
  local planetcount = flr((rnd()*.5+.5) * (1/ (.05 * abs(i) + 1)) * 10)
  for j=1 , planetcount do
    planettype = rndi(3)
    planets[i] = {x= rnd(sectorsize)+dsx*sectorsize, y=rnd(sectorsize)+dsy*sectorsize, type="planet",  planettype=planettype, shop={} }
    if(planettype == 1) then
      planets[i]['shop'][1] = {type="food", cost=rndi(3)}
      planets[i]['shop'][2] = {type="fuel", cost=rndi(3)}
      planets[i]['shop'][3] = {type="health", cost=rndi(3)}
    elseif(planettype == 2) then
      if rnd() < .35 then planets[i]['rumor'] = rndi(#relics) end
      planets[i]['shop'] = addshopitems({
      {prob=1.1, item={type="food",cost=rndi(3)}},
      {prob=0.5, item={type="fuel",cost=rndi(3)}},
      {prob=0.5, item={type="fuelupgrade", cost=rndi(3)+2}}, 
      {prob=0.5, item={type="foodupgrade", cost=rndi(3)+2}}})
      --planets[i]['shop'][1] = {type="fuel", cost=1}
    elseif(planettype == 3) then
      if rnd() < .65 then planets[i]['rumor'] = rndi(#relics) end
      planets[i]['shop'] = addshopitems({
        {prob=1.1, item={type="health", cost=rndi(3)}}, 
        {prob=0.5, item={type="fuel",cost=rndi(3)}},
        {prob=0.5, item={type="fuelupgrade", cost=rndi(3)+2}},
        {prob=0.5, item={type="healthupgrade", cost=rndi(3)+2}}})
    end
    i+=1
  end
end

function addshopitems(itemprobtable)
  local shop={}  
  
  for sp in all(itemprobtable) do
    if rnd() <= sp.prob then add(shop, sp.item) end
  end

  return shop
end


function drawexp()
    for p in all(smk) do
        local x = p.x - location.x + (p.sx - location.sectorx) * sectorsize
        local y = p.y - location.y + (p.sy - location.sectory) * sectorsize
        circfill(x,y,p.rad,p.clr)
    end
end

function spawnexp(x, y, sx,sy)
    for i=1,20 do
        add(smk,{x=x,y=y,sx=sx, sy=sy,
            dx=rnd(2)-1,dy=rnd(2)-1,
            rad=5,act=60,
            clr=rnd({5,6,7,13})})
    end
end

function updateexp()
    for p in all(smk) do
        p.x+=p.dx*0.5
        p.y+=p.dy*0.5
        p.act-=1
        if p.act<45 then p.rad=4 end
        if p.act<30 then p.rad=3 end
        if p.act<15 then p.rad=2 end
        if p.act<5 then p.rad=1 end
        if p.act<0 then
            del(smk,p)
        end
    end
end

function spawncoins(x,y,sx,sy,value)
  for i=1,value do
    local r = rnd()
    local vx = sin(r)
    local vy = cos(r)
    local cx = x + vx * 16
    local cy = y + vy * 16   
    add(coins,{x=x,y=y,sx=sx, sy=sy,vx=vx,vy=vy})
  end
end

function updatecoins()
  for c in all(coins) do
    c.x += c.vx
    c.y += c.vy
    c.vx *=.96
    c.vy *=.96
    if abs(c.sx - location.sectorx) + abs(c.sy - location.sectory) >= 3 then del(coins,c) end
  end
end

function drawcoins()
    for c in all(coins) do
        local x = c.x - location.x + (c.sx - location.sectorx) * sectorsize
        local y = c.y - location.y + (c.sy - location.sectory) * sectorsize
        spr(49,x,y)
        mag = vecmag(64 - x-4, 64 - y-4)
        if mag < 16 then
          money+=1          
          del(coins, c)
          sfx(06)
        end
    end
end

function damageplayer(d)
  sfx(03)
  health -= d
  damagedlastframe= true
  if health <= 0 then
    gameoverscreeninit()
  end
end

function spawnexhaust(x,y,r,speed,sprite)
  --printh("rot: " .. r)
  r += rnd() * .1 - .05
  --printh("rot rand" .. r)
  y+= (speed * cos(r)) * 5
  x+= (speed * sin(r)) * 5
  add(exhaust, {x=x, y=y, r=r ,speed=speed + rnd(), sprite=sprite, ttl=10} )
end

function updateexhaust()
  for e in all(exhaust) do
    e.x += e.speed * sin(e.r)
    e.y += e.speed * cos(e.r)
    e.ttl -= 1
    if(e.ttl <= 0) then del(exhaust, e) end
  end
end

function drawexhaust()  
  for e in all(exhaust) do
    ss = sslocfromid(e.sprite)    
    rspr(ss.x,ss.y,e.x,e.y,r,1)
    --sspr(ss.x, ss.y,8,8,e.x,e.y, scale, scale) 
  end
end