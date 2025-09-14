function splashscreeninit()
    interactcooldown = 30
    _update = splashscreenupdate
    _draw = splashscreendraw
end

function splashscreenupdate()
    if interactcooldown > 0 then interactcooldown-=1 end
    if ibtn(🅾️) or ibtn(❎) then
        _update = updatespace
        _draw = drawspace
        spaceinit()
    end
end

function splashscreendraw()
    cls()
    bigprint("space",10,24,9,8,3)
    bigprint("game",64,64,9,8,3) 
    sspr(1*32,32,32,32,80,13,32,32) 
    sspr(2*32,32,32,32,15,52,32,32) 

    printcentered("find the relics", 96)
    printcentered("save the universe", 108)
    printcentered("press any key", 120)
end

function _init()
    
    splashscreeninit()
    --winscreeninit()
    --gameoverscreeninit()

    debug=true
    palt(0,true)
    
    interactcooldown = 0
    stdinteractcooldown = 4
end