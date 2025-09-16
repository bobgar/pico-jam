function cheat(name)
    return activecheats[name]
end

function cheatsinit()
    codeprogress = {}
    cheatcodes = {}
    activecheats = {}
    cheatnames = {"cheat", "debug", "win", "mouseenabled","fastmode","allcry"}
    
    add(cheatcodes, {⬆️,⬆️,⬇️,⬇️,⬅️,➡️,⬅️,➡️,🅾️,❎,❎})
    add(cheatcodes, {⬆️,⬇️,🅾️,❎})
    add(cheatcodes, {⬇️,⬇️,🅾️,⬇️,⬇️,❎})
    add(cheatcodes, {⬆️,⬆️,🅾️,⬆️,⬆️,❎})
    add(cheatcodes, {➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️})
    add(cheatcodes, {⬅️,🅾️,➡️,➡️,🅾️,⬅️,❎})

    for i=1,#cheatcodes do
        add(codeprogress, 1)
        activecheats[cheatnames[i]] = false
    end
end

function updatecheatcode() 
    for i=1,#cheatcodes do
        --printh("cheat " .. cheatnames[i] .. "  progress " .. codeprogress[i])        
        if btnp( cheatcodes[i][codeprogress[i]] ) then    
            codeprogress[i] += 1         
            --printh("cheat " .. cheatnames[i] .. "  progress " .. codeprogress[i] .. "  length " .. #(cheatcodes[i][codeprogress[i]]) )
            if codeprogress[i] == #(cheatcodes[i]) then 
                activecheats[cheatnames[i]] = true
                sfx(16)
            end
        elseif anybuttonpressed() then codeprogress[i] = 1 end   
    end
    -- if btnp(cheatcode[cheatprogress]) then 
    --     cheatprogress+=1 
    --     if cheatprogress == #cheatcode + 1 then cheat=true end
    -- elseif anybuttonpressed() then cheatprogress=1 end    
    
    -- if btnp(debugcode[debugprogress]) then         
    --     debugprogress+=1 
    --     if debugprogress == #debugcode + 1 then debug=true end
    -- elseif anybuttonpressed() then debugprogress=1 end       

    -- if btnp(wincode[winprogress]) then         
    --     winprogress+=1 
    --     if winprogress == #wincode + 1 then winscreeninit() end
    -- elseif anybuttonpressed() then winprogress=1 end

    -- if btnp(mousecode[mouseprogress]) then         
    --     mouseprogress+=1 
    --     if mouseprogress == #mousecode + 1 then mouseenabled=true end
    -- elseif anybuttonpressed() then mouseprogress=1 end 
    
    -- if btnp(fastcode[fastprogress]) then         
    --     fastprogress+=1 
    --     if fastprogress == #fastcode + 1 then fastmode=true end
    -- elseif anybuttonpressed() then fastprogress=1 end   

    -- if btnp(crycode[cryprogress]) then         
    --     cryprogress+=1 
    --     if cryprogress == #crycode + 1 then allowlscry=true end
    -- elseif anybuttonpressed() then cryprogress=1 end 
end