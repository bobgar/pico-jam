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
    cheatnames = {"cheat", "debug", "win", "mousemode","fastmode","allcry", "nocls","owlarian", "pal","fps","nodrain", "free", "godgar", "nocheat"}
    
    add(cheatcodes, {⬆️,⬆️,⬇️,⬇️,⬅️,➡️,⬅️,➡️,🅾️,❎})
    add(cheatcodes, {⬆️,⬇️,🅾️,❎})
    add(cheatcodes, {⬇️,⬇️,🅾️,⬇️,⬇️,❎})
    add(cheatcodes, {⬆️,⬆️,🅾️,⬆️,⬆️,❎})
    add(cheatcodes, {➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️,➡️})
    add(cheatcodes, {⬅️,🅾️,➡️,➡️,🅾️,⬅️,❎})
    add(cheatcodes, {⬆️,➡️,⬇️,⬅️,⬆️,➡️,⬇️,⬅️})
    add(cheatcodes, {🅾️,❎,🅾️,❎,🅾️,❎,🅾️})
    add(cheatcodes, {⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️,⬅️})
    add(cheatcodes, {⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️,⬆️})
    add(cheatcodes, {⬇️,⬇️,⬇️,⬇️,⬇️,⬇️,⬇️,⬇️,⬇️,⬇️,⬇️,⬇️})
    add(cheatcodes, {🅾️,🅾️,🅾️,🅾️,🅾️,🅾️,🅾️,🅾️})
    add(cheatcodes, {🅾️,➡️,➡️,➡️,➡️,➡️,➡️,⬆️,⬆️,⬇️,⬇️})
    add(cheatcodes, {🅾️,➡️,⬅️,➡️,⬅️,⬇️,⬇️,⬆️,⬆️,❎ })

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
                initwavetext(cheatnames[i], 120, 90)
            end
            codeprogress[i] += 1
        elseif anybuttonpressed() then codeprogress[i] = 1 end   
    end    
end

function nocheat()
    for k,v in pairs(activecheats) do
        activecheats[k] = false
    end
end


function initwavetext(text, frames, ypos)
    wavetext = text
    wavetextframes = 1
    wavetextmaxframes = frames
    wavetextypos = ypos
end

function wavetextupdateanddraw()
    if wavetext == nil then return end
    local size = 15 
    local left = 64 - (#wavetext * 6) - 12
    for j=1, #wavetext do
        local offset = j*1.05
        local p = wavetextframes/wavetextmaxframes
        local ci = cos(p +offset)
        local si = sin(p+offset)
        local dxi = ci * size
        local dyi = si * size
        local col = abs(flr(si * 15))        
        bigprint(wavetext[j], left+j*12, wavetextypos + dyi, col, 1, 2)
    end 
    wavetextframes+=1
    if wavetextframes > wavetextmaxframes then wavetext = nil printh("wave text complete") end
end