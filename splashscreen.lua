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
        sfx(15)
    end
end

function splashscreendraw()
    cls()
    bigprint("bobgar's",64- #"bobgar's" * 4,4,6,4,2)
    --print("bobgar's", 64- #"bobgar's" * 2, 0)
    bigprint("space",10,32,9,8,3)
    bigprint("game",64,68,9,8,3) 
    sspr(1*32,32,32,32,80,21,32,32) 
    sspr(2*32,32,32,32,15,56,32,32) 
    color(7)
    printcentered("find the relics", 96)
    printcentered("save the universe", 108)
    printcentered("press any key", 120)
end

function _init()
    splashscreeninit()
    --winscreeninit()
    --gameoverscreeninit()

    debug=false
    palt(0,true)
    
    interactcooldown = 0
    stdinteractcooldown = 4
end