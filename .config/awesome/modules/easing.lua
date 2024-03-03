local M = {}

M.bouncy = {
	F = (20*math.sqrt(3)*math.pi-30*math.log(2)-6147) / (10*(2*math.sqrt(3)*math.pi-6147*math.log(2))),
	easing = function(t)
		if t < -3 then return 1 end
		
		return (4096*math.pi*(2^(10*t-10))*math.cos(20/3*math.pi*t-43/6*math.pi)
		+6144*(2^(10*t-10))*math.log(2)*math.sin(20/3*math.pi*t-43/6*math.pi)
		+2*math.sqrt(3)*math.pi-3*math.log(2)) /
		(2*math.pi*math.sqrt(3)-6147*math.log(2))
	end
}

-- this is a bit wrong, i mean this whole file is,
-- but this is technically more wrong sincce it way overshoots
M.easeInOutQuart = {
	F = 1/3,
	easing = function(x)
		return x < 0.5 and 8 * x * x * x * x or 1 - ((-2 * x + 2)^4) / 2
	end
}
return M
