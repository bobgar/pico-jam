function drawui()
  drawuibar(0,0,32,48,food,maxfood)
  drawuibar(0,8,33,48,fuel,maxfuel)
  drawuibar(0,16,34,48,health,maxhealth)
  drawsizeconstrainedcountuibar( max(128-money*8,64)  ,0,49,money, 64) 
  secstring = "sec " .. location.sectorx .. ',' .. location.sectory 
  print(secstring ,128 - #secstring * 4,10)
  print("relic", 128 - #"relic"*4 - 40, 20)
  drawrelicui()
end

function drawrelicui()
    local i = 0
    for r in all(relics) do 
        if r.found then spr(r.sprite, 120 - i*10, 20) end
        i+=1
    end
end

function drawdebugui()
  print("FPS: " .. stat(7), 80,100)
  print("CPU: " .. stat(1), 80,108)
  --printh("FPS: " .. stat(7))
  --printh("CPU: " .. stat(1))
end

function drawuibar(x,y,fsn,esn,c,m)
  i=0
  --printh(i .. ','.. c .. ','.. m)
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
  while i+1 <= m do 
    spr(esn,x+i*8,y)
    i+=1
  end
end

function drawsizeconstrainedcountuibar(x,y,s,c, maxsize)
  if c==0 then return end
  local spacing = min( (maxsize / c) ,8)
  local i=0
  --printh(i .. ','.. c .. ','.. m)
  while i+1 <= c do    
    spr(s,x+i*spacing,y)
    i+=1
  end
end
  