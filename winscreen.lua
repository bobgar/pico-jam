function winscreeninit()
    interactcooldown = 30
    _update = winscreenupdate
    _draw = winscreendraw
end

function winscreendraw()
    cls()
    bigprint("space",10,24,9,8,3)
    bigprint("game",64,64,9,8,3) 
    sspr(1*32,32,32,32,80,13,32,32) 
    sspr(2*32,32,32,32,15,52,32,32) 
    bigprint("you win!",32,96,9,8,2) 
    printcentered("press any key", 120)
end

function winscreenupdate()
    if interactcooldown > 0 then interactcooldown-=1 end
    if ibtn(🅾️) or ibtn(❎) then    
        splashscreeninit()
    end
end