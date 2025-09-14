function gameoverscreeninit()
    interactcooldown = 30
    _update = gameoverscreenupdate
    _draw = gameoverscreendraw
end

function gameoverscreendraw()
    cls()
    bigprint("game over",10,24,9,8,3)
    sspr(0,96,32,32,32,48,64,64)
    --bigprint("game",64,64,9,8,3) 
    --sspr(1*32,32,32,32,80,13,32,32) 
    --sspr(2*32,32,32,32,15,52,32,32) 
    --bigprint("you win!",32,96,9,8,2) 
    printcentered("press any key", 120)
end

function gameoverscreenupdate()
    if interactcooldown > 0 then interactcooldown-=1 end
    if ibtn(🅾️) or ibtn(❎) then    
        splashscreeninit()
    end
end