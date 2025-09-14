function sslocfromid(id)
    local sx = (id % 16) * 8
    local sy = (id \ 16) * 8
    return {x=sx, y=sy}
end

function ibtn(b)
  if btn(b) and interactcooldown<=0 then
    interactcooldown = stdinteractcooldown
    return true
  end
  return false
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