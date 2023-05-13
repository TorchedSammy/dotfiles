local beautiful = require 'beautiful'
local cairo = require 'lgi'.cairo
local gears = require 'gears'
local wibox = require 'wibox'

local base = {
	width = 12,
	radius = 6,
	gradientColors = beautiful.gradientColors or {
		'#86e0f0',
		'#9cfa74'
	},
}
base.shape = function(cr, w, h) return gears.shape.partially_rounded_rect(cr, w, h, false, true, false, true, base.radius) end
base.widths = {
	round = base.width + (base.width / 2),
	empty = base.width / 2,
}

function base.createGradient(w, h, startN, endN)
	w = w or base.width

	local gradient = gears.color.create_pattern {
		type  = 'linear' ,
		from  = {
			0,
			0
		},
		to = {
			w,
			h
		},
		stops = {
			{
				startN or 0,
				base.gradientColors[1]
			},
			{
				endN or 1,
				base.gradientColors[2]
			}
		}
	}

	return gradient
end

function base.gradientSurface(opts)
	opts.w = opts.w or base.width
	opts.gradient = opts.gradient or base.createGradient(opts.w, opts.h)

	local img = cairo.ImageSurface.create(cairo.Format.ARGB32, opts.w, opts.h)
	local cr = cairo.Context(img)
	cr:set_source(opts.gradient)
	cr:paint()

	return img
end

function base.sideDecor(opts)
	local position = opts.position or 'left'
	local img = base.gradientSurface(opts)

	local gradientBar = wibox.widget {
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
		},
		shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, opts.enforceHeight and opts.h or h, false, false, false, true, base.radius) end,
		bgimage = img,
		widget = wibox.container.background,
		forced_width = opts.noRounder and base.width / 2 or base.width,
		forced_height = opts.h
	}

	local round = wibox.widget {
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
		},
		shape = function(crr, w, _) return gears.shape.partially_rounded_rect(crr, w, opts.h, false, false, false, true, base.radius) end,
		bg = opts.bg or beautiful.bg_normal,
		widget = wibox.container.background,
		forced_width = opts.emptyLen or base.widths.round,
		forced_height = opts.h
	}

	local empty = wibox.widget {
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
		},
		shape = function(cr, w, h) return gears.shape.rectangle(cr, w, h) end,
		bg = '#00000000',
		widget = wibox.container.background,
		forced_width = base.widths.empty
	}

	local rounder = opts.noRounder and {} or {empty, round}
	local side = wibox.widget {
		layout = wibox.layout.stack,
		expand = 'none',
		gradientBar,
		{
			layout = wibox.layout.fixed.horizontal,
			table.unpack(rounder)
		}
	}
	if position == 'right' then
		side = wibox.widget {
			widget = wibox.container.mirror,
			reflection = {
				horizontal = true,
				vertical = true
			},
			side
		}
	end
	if position == 'top' then
		side = wibox.widget {
			widget = wibox.container.rotate,
			direction = 'west', -- this is weird.
			side
		}
	end
		if position == 'bottom' then
		side = wibox.widget {
			widget = wibox.container.rotate,
			direction = 'east', -- this is weird.
			side
		}
	end
	return side
end

return base
