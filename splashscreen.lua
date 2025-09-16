function splashscreeninit()
    _update = splashscreenupdate
    _draw = splashscreendraw
end

function splashscreenupdate()
    updatecheatcode()

    if btnp(❎) then
        _update = updatespace
        _draw = drawspace
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
    printcentered("❎ play  🅾️ help", 120)
end

function _init()
    debug = false
    cheat = false
    mouseenabled = false

    splashscreeninit()
    --winscreeninit()
    --gameoverscreeninit()

    palt(0,true)
    cheatprogress = 1
    cheatcode = {⬆️,⬆️,⬇️,⬇️,⬅️,➡️,⬅️,➡️,🅾️,❎,❎}
    
    debugprogress = 1
    debugcode = {⬆️,⬇️,🅾️,❎}

    winprogress = 1
    wincode = {⬇️,⬇️,🅾️,⬇️,⬇️,❎}

    mouseprogress = 1
    mousecode = {⬆️,⬆️,🅾️,⬆️,⬆️,❎}
end

function updatecheatcode() 
    if btnp(cheatcode[cheatprogress]) then 
        cheatprogress+=1 
        if cheatprogress == #cheatcode + 1 then cheat=true end
    elseif anybuttonpressed() then cheatprogress=1 end    
    
    if btnp(debugcode[debugprogress]) then         
        debugprogress+=1 
        if debugprogress == #debugcode + 1 then debug=true end
    elseif anybuttonpressed() then debugprogress=1 end       

    if btnp(wincode[winprogress]) then         
        winprogress+=1 
        if winprogress == #wincode + 1 then winscreeninit() end
    elseif anybuttonpressed() then winprogress=1 end

    if btnp(mousecode[mouseprogress]) then         
        mouseprogress+=1 
        if mouseprogress == #mousecode + 1 then mouseenabled=true end
    elseif anybuttonpressed() then mouseprogress=1 end   
end