function winscreeninit()
    _update = winscreenupdate
    _draw = winscreendraw
    particles = {}
    firecounter = 30
    cheatnames["win"] = false
    sfx(13)
end

function winscreendraw()
    cls()
    bigprint("bobgar's",64- #"bobgar's" * 4,4,6,4,2)
    bigprint("space",10,32,9,8,3)
    bigprint("game",64,68,9,8,3) 
    sspr(1*32,32,32,32,80,21,32,32) 
    sspr(2*32,32,32,32,15,56,32,32) 
    bigprint("you win!",32,96,9,8,2) 
    color(7)
    printcentered("press any key", 120)

    drawparticles()
end

function winscreenupdate()
    if btnp(🅾️) or btnp(❎) then    
        splashscreeninit()
        sfx(15)
    end

    firecounter-=1
    if firecounter ==10 then        
        boom(rnd(128),rnd(64))
    end
    if firecounter == 5 then
        boom(rnd(128),rnd(64))
    end
    if firecounter == 0 then
        boom(rnd(128),rnd(64))
        firecounter = 60
    end
    
    updateparticles()
end

function boom(_x,_y)
 sfx(14)
 -- crate 100 particles at a location
 for i=0,100 do
  spawn_particle(_x,_y)
 end
end

function spawn_particle(_x,_y)
 -- create a new particle
 local new={}
 
 -- generate a random angle
 -- and speed
 local angle = rnd()
 local speed = 1+rnd(2)
 
 new.x=_x --set start position
 new.y=_y --set start position
 -- set velocity based on
 -- speed and angle
 new.dx=sin(angle)*speed
 new.dy=cos(angle)*speed
 
 --add a random starting age
 --to add more variety
 new.age=flr(rnd(25))
 
 --add the particle to the list
 add(particles,new)
end

function updateparticles()
 --iterate trough all particles
 for p in all(particles) do
  --delete old particles
  --or if particle left 
  --the screen 
  if p.age > 80 
   or p.y > 128
   or p.y < 0
   or p.x > 128
   or p.x < 0
   then
   del(particles,p)
  else
  
   --move particle
   p.x+=p.dx
   p.y+=p.dy
   
   --age particle
   p.age+=1
   
   --add gravity
   p.dy+=0.15
  end
 end
end

function drawparticles() 
--iterate trough all particles
 local col
 for p in all(particles) do
  --change color depending on age
  if p.age > 60 then col=8
  elseif p.age > 40 then col=9
  elseif p.age > 20 then col=10  
  else col=7 end
  
  --actually draw particle
  line(p.x,p.y,p.x+p.dx,p.y+p.dy,col)
  
  --you can also draw simpler
  --particles like this
  --pset(p.x,p.y,col)

 end
end
