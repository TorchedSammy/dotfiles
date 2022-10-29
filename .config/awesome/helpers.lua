local awful = require 'awful'
local gears = require 'gears'
local wibox = require 'wibox'
local beautiful = require 'beautiful'

local helpers = {}

function helpers.rrect(radius)
	return function(c, width, height)
		gears.shape.rounded_rect(c, width, height, radius)
	end
end

function helpers.colorize_text(text, color)
	return '<span foreground="' .. color ..'">' .. text .. '</span>'
end

function helpers.set_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == 'function' then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

function helpers.maximize(c)
    c.maximized = not c.maximized
    if c.maximized then
        helpers.winmaxer(c)
    end
    c:raise()
end

function helpers.winmaxer(c)
  awful.placement.maximize(c, {
    honor_padding = true,
    honor_workarea = true,
    margins = beautiful.useless_gap * 2
  })
end
return helpers

