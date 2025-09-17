function helpinit()
    setupdatefunctions(helpupdate, helpdraw)
    pages = {page1, page2, page3, page4, page5, page6, page7}
    printh(#pages)
    curpageidx = 1
    defaulthelptextcolor = 2
end

function helpupdate()
    if btnp(⬅️) and curpageidx > 1 then curpageidx -=1 end
    if btnp(➡️) and curpageidx < #pages then curpageidx +=1 end

    if btnp(❎) or btnp(🅾️) then splashscreeninit() end
    updatecheatcode()
end

function helpdraw()
    cls(7)    
    local xpos = 128- (#pages - curpageidx)
    color(9)
    
    rectfill(xpos ,0,128,128)
    pset(xpos-1, 0)
    pset(xpos-2, 0)
    pset(xpos-1, 1)
    pset(xpos-1, 127)
    pset(xpos-2, 127)
    pset(xpos-1, 126)

    color(4)
    pset(127,0)
    pset(127,1)
    pset(126,0)
    pset(127,127)
    pset(126,127)
    pset(127,126)

    color(defaulthelptextcolor)
    pages[curpageidx]()
    printcentered("⬅️ page " .. curpageidx .. " / " .. #pages .. " ➡️", 112)    
    printcentered("❎🅾️ leave", 120)    
end

function page1()
    print("  ⬅️➡️  rotate ship",2, 8)
    print("  ⬆️⬇️  thrust",2, 16)
    print("  ❎    fire",2, 24)
    print("  🅾️    interact",2, 32)

    spr(49, 10, 38) print("        space money", 2, 40)    
    spr(32, 10, 46) print("        food", 2, 48)
    spr(33, 10, 54) print("        fuel", 2, 56)
    spr(34, 10, 62) print("        health", 2, 64)
    spr(32, 10, 70) spr(50, 10, 70) print("        food upgrade", 2, 72)
    spr(33, 10, 78) spr(50, 10, 78) print("        fuel upgrade", 2, 80)
    spr(34, 10, 86) spr(50, 10, 86) print("        health upgrade", 2, 88)
end

function page2()
    spr(64, 2, 12,2,2) spr(66, 26, 12,2,2) spr(96, 50, 12,2,2) print("iron  gold diamond", 2, 2) color(5) print("asteroids", 80, 16) color(defaulthelptextcolor)
    
    local refy = 35
    print("bandit", 2, refy) print("relic guard", 36, refy)
    spr(140, 5, refy+10,2,2) spr(158, 23, refy+10, 1, 1)  spr(138, 50, refy+10,2,2) spr(142, 68, refy+10, 1, 1)  color(8) print("enemies", 80,refy+14) color(defaulthelptextcolor)

    refy = 68
    print("human", 2, refy) print("lizard", 26, refy) print("owl", 60, refy)
    local temploc = sslocfromid(3) 
    sspr(temploc.x, temploc.y,32,32,2,refy + 10, 16,16)

    local temploc = sslocfromid(7) 
    sspr(temploc.x, temploc.y,32,32,30,refy + 10, 16,16)

    local temploc = sslocfromid(11) 
    sspr(temploc.x, temploc.y,32,32,58,refy + 10, 16,16)
    color(11) print("planets", 80,refy+14) color(defaulthelptextcolor)
end

function page3()
    printcentered("story", 6)
    print("in ancient times the owlonians\nruled the galaxy.\n\nThey built a device of great\npower that in the hands of \ngood could protect the galaxy\nfrom destruction.\n\nIn the wrong hads, it could\ncause destruction so they hid\nits location with four mystic\nrelics.\n\nIt is guarded by powerful\nbeings to keep it safe.\n", 4, 16)
end

function page4()
    local temploc = sslocfromid(68) 
    rectfill(6, 6, 74,74, 1) 
    sspr(temploc.x, temploc.y,32,32,8, 8, 64,64)
    color(defaulthelptextcolor)
    print("humans", 78, 8)
    print("Helpful but naive", 6, 80)
    print("always trades", 6, 90) spr(32, 60, 88) spr(33, 70, 88) spr(34, 80, 88)
    print("costs 1-3", 6, 100) spr(49, 42, 98)
end

function page5()
    local temploc = sslocfromid(72) 
    rectfill(6, 6, 74,74, 1) 
    sspr(temploc.x, temploc.y,32,32,8, 8, 64,64)
    color(defaulthelptextcolor)
    print("lizamon", 78, 8)
    print("expert traders", 6, 80)
    print("always trades", 6, 90) spr(32, 60, 88)
    print("sometimes trades", 6, 100) spr(33, 70, 98) spr(32, 80, 98) spr(50, 80, 98) spr(33, 90, 98) spr(50, 90, 98)
end

function page6()
    local temploc = sslocfromid(76) 
    rectfill(6, 6, 74,74, 1) 
    sspr(temploc.x, temploc.y,32,32,8, 8, 64,64)
    color(defaulthelptextcolor)
    print("owlarian", 78, 8)
    print("mystic artificers", 6, 80)
    print("always trades", 6, 90) spr(34, 60, 88)
    print("sometimes trades", 6, 100) spr(33, 70, 98) spr(34, 80, 98) spr(50, 80, 98) spr(33, 90, 98) spr(50, 90, 98)
end

function page7()
    printcentered("strategy", 6)
    print("there are more planets toward\nsector 0,0\n\nowls and sometimes lizards\nknow the location of relics\n\nbandits are more common\nfar from sector 0,0\n\n⬆️⬆️🅾️⬆️⬆️❎ to enable mouse\n\nbobgar.com is the place\nfor all your bobgar needs", 4, 16)
end

function anybuttonpressed()
    return btnp(⬆️) or btnp(⬇️) or btnp(⬅️) or btnp(➡️) or btnp(🅾️) or btnp(❎)
end