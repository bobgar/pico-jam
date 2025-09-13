function _init()
  debug=true
  palt(0,true)
  inittimeforseeds = stat(0)
  _update = updatespace
  _draw = drawspace
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
  bulletIdx = 1
  maxBullets = 5
  bulletSpeed = 2.0
  fireRate = 16
  timeSinceFire = 0
  bullets={}
  sinr = 0
  cosr = 0
  stars = {}  
  curinteractible = nil
  interactcooldown = 0
  stdinteractcooldown = 4
  for i=0, 500 do
    stars[i] = {x=rndi(sectorsize),y=rndi(sectorsize)}
  end
  relics={}
  --relicactivated=false
  relicactivated=true
  for i=1, 4 do
    --relics are in sectors at random direction on unit circle scaled by distance
    r = rnd()
    d = rnd()*10+20
    if i==1 then s = 132 end
    if i==2 then s = 133 end
    if i==3 then s = 148 end
    if i==4 then s = 149 end
    relics[i] = {x=flr( sin(r)*d), y=flr(cos(r)*d), found=false, sprite=s, type="relic"}
  end

  relics[1].x = 1
  relics[1].y = 1

  r = rnd()
  d = rnd()*20+30
  --anomaly = {x=flr( sin(r)*d), y=flr(cos(r)*d)}
  anomaly = {x=3, y=-3}
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
  if(btn(🅾️)) and timeSinceFire > fireRate then 
    timeSinceFire = 0
    local bvx = -sin(r)*bulletSpeed
    local bvy = -cos(r)*bulletSpeed
    bullets[bulletIdx]={x=64+bvx*2,y=64+bvy*2,vx=bvx+vx,vy=bvy+vy, r=atan2(-bvy,-bvx)}  
    bulletIdx+=1  
    if bulletIdx > maxBullets then
      bulletIdx = 1
    end
  end
  for b in all( bullets ) do
    b.x+=b.vx
    b.y+=b.vy
  end

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
    cls()
    stop("You ran out of food\nGame Over!")
  end
end

function drawspace()  
  cls()
  drawstars()
  drawplanets()
  drawrelic()

  --draw ship
  rspr(8,0,64-8,64-8,r,2)
  
  --if activated draw relic
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
        --_update = winscreenupdate
        --_draw = winscreendraw
      end
    end
  end

  for b in all( bullets ) do
    rspr(0,8,b.x,b.y,b.r,1)
  end
  --print('sx= ' .. location.sectorx .. '  sy= ' .. location.sectory)
  drawuibar(0,0,32,48,food,maxfood)
  drawuibar(0,8,33,48,fuel,maxfuel)
  drawuibar(0,16,34,48,health,maxhealth)
  
  drawui()  
  if debug then
    drawdebugui()
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

      if debug then pset(x,y,14) end
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
end

function addplanetsforsector(dsx,dsy)
  sx = location.sectorx+dsx
  sy = location.sectory+dsy
  sd = abs(sx) + abs(sy)
  srand(sx * 123 + sy * 17 + inittimeforseeds)
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