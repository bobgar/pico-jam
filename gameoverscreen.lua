function gameoverscreeninit()
    setupdatefunctions(gameoverscreenupdate, gameoverscreendraw)
    sfx(12)
end

function gameoverscreendraw()
    cls()
    bigprint("game over",10,24,9,8,3)
    local loc = sslocfromid(76)
    sspr(loc.x,loc.y,32,32,32,48,64,64)
    loc = sslocfromid(200)
    sspr(0,96,32,32,32,48,64,64)
    --sspr(0,96,32,32,32,48,64,64)
    --bigprint("game",64,64,9,8,3) 
    --sspr(1*32,32,32,32,80,13,32,32) 
    --sspr(2*32,32,32,32,15,52,32,32) 
    --bigprint("you win!",32,96,9,8,2) 
    color(7)
    printcentered("press any key", 120)
end

function gameoverscreenupdate()
    if btnp(🅾️) or btnp(❎) then    
        splashscreeninit()
        sfx(15)
    end
end