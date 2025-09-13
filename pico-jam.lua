function _init()
  palt(0,true)
  inittimeforseeds = stat(0)
  state="space"
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
  hungerrate = .001
  vx=0
  vy=0
  vs=.3
  rs=.0025
  rd=0.95
  damp=0.9
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
  for i=0, 1000 do
    stars[i] = {x=rndi(sectorsize),y=rndi(sectorsize)}
  end
  relics={}
  for i=1, 5 do
    --relics are in sectors at random direction on unit circle scaled by distance
    r = rnd()
    d = rnd()*50+50
    relics[i] = {x=flr( sin(r)*d), y=flr(cos(r)*d)}
  end
  changeSectors()
end

function _update()
  if state=="space" then
    updatespace()
  end
end

function updatespace()
  if (btn(⬅️)) then rv-=rs end
  if (btn(➡️)) then rv+=rs end
  if (btn(⬆️) and fuel >= 0) then vy-=cos(r)*vs vx-=sin(r)*vs fuel -= fuelburnrate end
  if (btn(⬇️) and fuel >= 0) then vy+=cos(r)*vs vx+=sin(r)*vs fuel -= fuelburnrate end
  if (btn(❎) and curinteractible != nil) then
    state="planet"
    return
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

function _draw()
  cls(0) 
  if state == "space" then
    drawspace()
  elseif state == "planet" then
    drawplanet()
  end
  drawui()
end

function drawplanet()
    sspr(curinteractible.type*32,32,32,32,64,32,64,64) 
end

function drawspace()
  drawstars()
  drawplanets()
  rspr(8,0,64,64,r,2)
  for b in all( bullets ) do
    rspr(0,8,b.x,b.y,b.r,1)
  end
  --print('sx= ' .. location.sectorx .. '  sy= ' .. location.sectory)
  drawuibar(0,0,32,48,food,maxfood)
  drawuibar(0,8,33,48,fuel,maxfuel)
  drawuibar(0,16,34,48,health,maxhealth)
end

function drawui()
  drawuibar(0,0,32,48,food,maxfood)
  drawuibar(0,8,33,48,fuel,maxfuel)
  drawuibar(0,16,34,48,health,maxhealth)
end

function drawuibar(x,y,fsn,esn,c,m)
  i=0
  while i+1 <= c do    
    spr(fsn,x+i*8,y)
    i+=1
  end
  if( i+1 <= m) then 
    local sx = (fsn % 16) * 8
    local sy = (fsn \ 16) * 8
    local mid = (c%1) * 8
    sspr(sx, sy, mid,8, x+i*8,y)
    sx = (esn % 16) * 8
    sy = (esn \ 16) * 8
    sspr(sx+mid, sy, 8-mid + 1,8, x+i*8+mid,y)
    i+=1
  end
  while i+1 <= maxfood do 
    spr(esn,x+i*8,y)
    i+=1
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
      
      sspr(-8 + p.type*32,0,32,32,x,y) 
      if x>=40 and x <= 72 and y >= 40 and y<=72 then
        curinteractible = p
        sspr(0,64,32,32,x,y)        
      end
    end
    i+=1
  end
end

function rspr(sx,sy,x,y,a,w)
	local ca,sa=cos(a),sin(a)
	local srcx,srcy
	local ddx0,ddy0=ca,sa
	local mask=shl(0xfff8,(w-1))
	w*=4
	ca*=w-0.5
	sa*=w-0.5
	local dx0,dy0=sa-ca+w,-ca-sa+w
	w=2*w-1
	for ix=0,w do
		srcx,srcy=dx0,dy0
		for iy=0,w do
			if band(bor(srcx,srcy),mask)==0 then
				local c=sget(sx+srcx,sy+srcy)
                if c != 0 then
				    pset(x+ix,y+iy,c)
                end
			end
			srcx-=ddy0
			srcy+=ddx0
		end
		dx0+=ddx0
		dy0+=ddy0
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
  srand(sx * 123+sy * 17 + inittimeforseeds)
  --generate at most 4 planets
  planetcount = rnd() * (1/ (.2 * sd+1)) * 5
  for j=0,planetcount do
    --TODO make planet type  more human close to start and more aliens as you get further out
    planettype = rndi(3)
    planets[i] = {x= rnd(sectorsize)+dsx*sectorsize, y=rnd(sectorsize)+dsy*sectorsize, type=planettype, shop={}}
    if(planettype == 0) then
      --todo randomize this
      planets[i]['shop'][1] = {type="Fuel", cost=rndi(3)}
      planets[i]['shop'][2] = {type="Food", cost=rndi(3)}
    elseif(planettype == 1) then
      if rnd() < .25 then planets[i]['romur'] = rndi(#relics) end
    else
    end
    i+=1
  end
end
function rndi(limit)
  return 1+flr(rnd(limit))
end 