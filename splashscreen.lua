function splashscreeninit()
    setupdatefunctions(splashscreenupdate,splashscreendraw)
end

function splashscreenupdate()
    updatecheatcode()
    if(cheat("win")) then winscreeninit() end
    if(cheat("clearcheats")) then clearcheats() end

    if btnp(❎) then
        spaceinit()
        sfx(15)
    elseif btnp(🅾️) then
        helpinit()
    end
end

function splashscreendraw()
    cls()
    bigprint("bobgar's",64- #"bobgar's" * 4,4,6,4,2)
    bigprint("space",10,32,9,8,3)
    bigprint("game",64,68,9,8,3) 
    sspr(1*32,32,32,32,80,21,32,32) 
    sspr(2*32,32,32,32,15,56,32,32) 
    color(7)
    printcentered("find the relics", 96)
    printcentered("save the universe", 108)
    printcentered("🅾️ manual   ❎ play", 120)
end

function _init()
    cheatsinit()
    splashscreeninit()
    --winscreeninit()
    --gameoverscreeninit()

    palt(0,true)
end