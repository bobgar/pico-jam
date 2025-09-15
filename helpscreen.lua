function helpinit()
    _update = helpupdate
    _draw = helpdraw
    pages = {page1, page2}
    curpageidx = 1
end

function helpupdate()
    if btnp(⬅️) and curpageidx > 1 then curpageidx -=1 end
    if btnp(➡️) and curpageidx < #pages then curpageidx +=1 end

    if btnp(❎) or btnp(🅾️) then splashscreeninit() end
end

function helpdraw()
    cls()
    pages[curpageidx]()
    printcentered("⬅️ page " .. curpageidx .. " / " .. #pages .. " ➡️", 112)    
    printcentered("❎🅾️ leave", 120)    
end

function page1()
    print("⬅️➡️ rotate ship",2, 8)
    print("⬆️⬇️ thrust",2, 16)
    print("❎   fire",2, 24)
    print("🅾️   interact",2, 32)

    spr(49, 1, 38) print("     space money", 2, 40)    
    spr(32, 1, 46) print("     food", 2, 48)
    spr(33, 1, 54) print("     fuel", 2, 56)
    spr(34, 1, 62) print("     health", 2, 64)
    spr(32, 1, 70) spr(50, 1, 70) print("     food upgrade", 2, 72)
    spr(33, 1, 78) spr(50, 1, 78) print("     fuel upgrade", 2, 80)
    spr(34, 1, 86) spr(50, 1, 86) print("     health upgrade", 2, 88)
end

function page2()
    spr(64, 2, 12,2,2) spr(66, 26, 12,2,2) spr(96, 50, 12,2,2) print("iron  gold diamond", 2, 2) color(6) print("asteroids", 80, 16) color(7)
    
    local refy = 35
    print("bandit", 2, refy) print("relic guard", 36, refy)
    spr(140, 5, refy+10,2,2) spr(158, 23, refy+10, 1, 1)  spr(138, 50, refy+10,2,2) spr(142, 68, refy+10, 1, 1)  color(8) print("enemies", 80,refy+14) color(7)

    refy = 68
    print("human", 2, refy) print("lizard", 26, refy) print("owl", 60, refy)
    local temploc = sslocfromid(3) 
    sspr(temploc.x, temploc.y,32,32,2,refy + 10, 16,16)

    local temploc = sslocfromid(7) 
    sspr(temploc.x, temploc.y,32,32,30,refy + 10, 16,16)

    local temploc = sslocfromid(11) 
    sspr(temploc.x, temploc.y,32,32,58,refy + 10, 16,16)
    color(11) print("planets", 80,refy+14) color(7)
end