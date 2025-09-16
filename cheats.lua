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
end