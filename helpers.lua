function sslocfromid(id)
    local sx = (id % 16) * 8
    local sy = (id \ 16) * 8
    return {x=sx, y=sy}
end

function rspr(sx,sy,x,y,a,w)
	local ca,sa=cos(a),sin(a)
	local srcx,srcy
	local ddx0,ddy0=ca,sa
	local mask=shl(0xfff8,(w-1))
	w*=4
	ca*=w-0.5
	sa*=w-0.5
	local dx0,dy0=sa-ca+w,-ca-sa+w
	w=2*w-1
	for ix=0,w do
		srcx,srcy=dx0,dy0
		for iy=0,w do
			if band(bor(srcx,srcy),mask)==0 then
				local c=sget(sx+srcx,sy+srcy)
                if c != 0 then
				    pset(x+ix,y+iy,c)
                end
			end
			srcx-=ddy0
			srcy+=ddx0
		end
		dx0+=ddx0
		dy0+=ddy0
	end
end

function vecmag(x,y)
	x /= 10.0
	y /= 10.0
    return sqrt(x * x + y * y) * 10.0
end

function oprint(str,x,y,c,co) --outline print
    for xx=-1,1,1 do
        for yy=-1,1,1 do
            print(str,x+xx,y+yy,co)
        end
    end
    print(str,x,y,c)
end

function bigprint(str,x,y,c,co,scale)
    poke(0x5f54,0x60) -- screen is spritesheet. spr and sspr use screen as source
    oprint(str,x,y,c,co) -- outline print to desired location
    local x0 = x-1
    local y0 = y-1
    local w = #str*4 + 2
    local h = 7 -- only works on single line strings for now
    palt(0b1111111111111111) -- set all colors transparent
    palt(c,false) -- only draw the text and outline colors
    palt(co,false)
    sspr(x0,y0,w,h,x0,y0,w*scale,h*scale) -- stretch the text with desired scale
    palt()
    poke(0x5f54,0x00) -- set spritesheet back to source for spr
end

function printcentered(text, y)
	print(text, 64 - #text*2, y)
end

function rndi(limit)
  return 1+flr(rnd(limit))
end 
