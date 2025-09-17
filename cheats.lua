function cheat(name)
    return activecheats[name]
end

function cheatcodeasstring(c)
    local returnstring = ""
    for i in all(cheatcodes[c]) do
        local j=""
        if i == ⬆️ then j = "⬆️" end
        if i == ⬇️ then j = "⬇️" end
        if i == ⬅️ then j = "⬅️" end
        if i == ➡️ then j = "➡️" end
        if i == 🅾️ then j = "🅾️" end
        if i == ❎ then j = "❎" end
        returnstring = returnstring .. j
    end
    return returnstring
end

function cheatsinit()
    codeprogress = {}
    cheatcodes = {}
    activecheats = {}
    cheatnames = {"cheat", "debug", "win", "mouseenabled","fastmode","allcry", "nocls","owlarian", "pal","fps"}
    
    add(cheatcodes, {⬆️,⬆️,⬇️,⬇️,⬅️,➡️,⬅️,➡️,🅾️,❎,❎})
    add(cheatcodes, {⬆️,⬇️,🅾️,❎})
    add(cheatcodes, {⬇️,⬇️,🅾️,⬇️,⬇️,❎})
    add(cheatcodes, {⬆️,⬆️,🅾️,⬆️,⬆️,❎})
    add(cheatcodes, {➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️})
    add(cheatcodes, {⬅️,🅾️,➡️,➡️,🅾️,⬅️,❎})
    add(cheatcodes, {⬆️,➡️,⬇️,⬅️,⬆️,➡️,⬇️,⬅️})
    add(cheatcodes, {🅾️,❎,🅾️,❎,🅾️,❎,🅾️})
    add(cheatcodes, {⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️})
    add(cheatcodes, {⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️})

    for i=1,#cheatcodes do
        add(codeprogress, 1)
        activecheats[cheatnames[i]] = false
    end
end

function updatecheatcode() 
    for i=1,#cheatcodes do
        --printh("cheat " .. cheatnames[i] .. "  progress " .. codeprogress[i])        
        if btnp( cheatcodes[i][codeprogress[i]] ) then                         
            --printh("cheat " .. cheatnames[i] .. "  progress " .. codeprogress[i] .. "  length " .. #(cheatcodes[i][codeprogress[i]]) )
            if codeprogress[i] == #(cheatcodes[i]) then 
                activecheats[cheatnames[i]] = true
                sfx(16)
            end
            codeprogress[i] += 1
        elseif anybuttonpressed() then codeprogress[i] = 1 end   
    end
end