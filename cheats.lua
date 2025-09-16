function cheatsinit()
    cheat = false
    cheatprogress = 1
    cheatcode = {⬆️,⬆️,⬇️,⬇️,⬅️,➡️,⬅️,➡️,🅾️,❎,❎}

    debug = false
    debugprogress = 1
    debugcode = {⬆️,⬇️,🅾️,❎}

    winprogress = 1
    wincode = {⬇️,⬇️,🅾️,⬇️,⬇️,❎}

    mouseenabled = false
    mouseprogress = 1
    mousecode = {⬆️,⬆️,🅾️,⬆️,⬆️,❎}

    fastmode = false
    fastprogress = 1
    fastcode = {➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️}

    allowlscry=false
    cryprogress = 1
    crycode = {⬅️,🅾️,➡️,➡️,🅾️,⬅️,❎}
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
    
    if btnp(fastcode[fastprogress]) then         
        fastprogress+=1 
        if fastprogress == #fastcode + 1 then fastmode=true end
    elseif anybuttonpressed() then fastprogress=1 end   

    if btnp(crycode[cryprogress]) then         
        cryprogress+=1 
        if cryprogress == #crycode + 1 then allowlscry=true end
    elseif anybuttonpressed() then cryprogress=1 end 
end