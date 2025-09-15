function updateplanet()
  if btnp(⬆️) and cursorloc>0 then cursorloc-=1 end
  if btnp(⬇️) and cursorloc<maxcursorloc then cursorloc+=1 end
  if btnp(❎) then     
    if cursorloc == maxcursorloc then 
      _update = updatespace
      _draw = drawspace
      sfx(11)
    elseif cursorloc == 0 and curinteractible.rumor != nil then
      sfx(09)
      lastsaid = "You should check sector " .. relics[curinteractible.rumor].x .. ',' .. relics[curinteractible.rumor].y
    else      
      local i=cursorloc
      if curinteractible.rumor == nil then i+=1 end
      --printh(i .. ' type ' .. curinteractible.shop[i].type .. ' cost ' .. curinteractible.shop[i].cost)
      --TODO find a more clever way to do this.
      if curinteractible.shop[i].cost <= money then 
        local bought = false
        if curinteractible.shop[i].type == 'food' and food < maxfood then food = min(food+1, maxfood) money -= curinteractible.shop[i].cost bought=true end
        if curinteractible.shop[i].type == 'fuel' and fuel < maxfuel then fuel = min(fuel+1, maxfuel) money -= curinteractible.shop[i].cost bought=true end
        if curinteractible.shop[i].type == 'health' and health < maxhealth then health = min(health+1, maxhealth) money -= curinteractible.shop[i].cost bought=true end
        if curinteractible.shop[i].type == 'foodupgrade' then maxfood+=1 food = min(food+1, maxfood) money -= curinteractible.shop[i].cost bought=true end
        if curinteractible.shop[i].type == 'fuelupgrade' then maxfuel+=1 fuel = min(fuel+1, maxfuel) money -= curinteractible.shop[i].cost bought=true end
        if curinteractible.shop[i].type == 'healthupgrade' then maxhealth+=1 health = min(health+1, maxhealth) money -= curinteractible.shop[i].cost bought=true end        
        if bought then sfx(08) end
      end
    end
  end  
end 

function drawplanet()
    cls()
    sspr(curinteractible.planettype*32,32,32,32,64,32,64,64) 
    y=32

    print(">", 0,y+10*cursorloc)

    if curinteractible.rumor ~= nil then print("rumor", 8,y) y+=10 end
    
    for s in all(curinteractible['shop']) do      
      drawicon(s.type,7,y-1)
      print("=>",20,y)      
      drawuibar(31,y-1,49,49,s.cost,s.cost )
      y+=10
    end
    
    print("exit", 8,y)
    print(lastsaid, 64 - #lastsaid*2, 120)

    drawui()
    if debug then
      drawdebugui()
    end
end


function drawicon(icon,x,y) 
  if icon == "food" or icon == "foodupgrade" then spr(32,x,y) end
  if icon == "fuel" or icon == "fuelupgrade" then spr(33,x,y) end
  if icon == "health" or icon == "healthupgrade"  then spr(34,x,y) end
  if icon == "foodupgrade" or icon == "fuelupgrade" or icon == "healthupgrade" then spr(50,x,y) end  
end