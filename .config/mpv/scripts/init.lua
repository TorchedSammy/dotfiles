local mp = require 'mp'

local opts = {
	keep_open = 'yes',
	hwdec = 'auto',
	deband = 'no',
	sigmod_upscaling = 'no',
	correct_downscaling = 'no',
	dither_depth = 'no',
	scale = 'bilinear',
	cscale = 'bilinear',
	dscale = 'bilinear',
	scale_antiring = 0,
	cscale_antiring = 0,
	geometry = '25%'
}
for opt, arg in pairs(opts) do
	mp.set_property('options/' .. opt:gsub('_', '-'), arg)
end
