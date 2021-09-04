local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local naughty = require 'naughty'
local taglist = require 'ui.taglist'
local widgets = require 'ui.widgets'
local wibox = require 'wibox'

screen.connect_signal('property::geometry', helpers.set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	-- Our actual bar will be transparent,
	-- then we add the smaller bars inside of it
	s.bar = awful.wibar {
		screen = s,
		position = 'bottom',
		height = beautiful.wibar_height,
		width = s.geometry.width - 5,
		shape = gears.shape.rounded_bar, -- to change the shape of the bars, change here
		bg = '#00000000' -- make it transparent black
	}

	-- float from the bottom slightly
	-- specifically by 36px
	s.bar.y = s.geometry.height - 36

	-- First bar: workspaces
	local workspaces = wibox.widget {
		{
			{
				layout = wibox.layout.fixed.horizontal,
				taglist(s)	
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
			up = 4
		},
		shape = s.bar.shape,
		bg = beautiful.wibar_bg,
		widget = wibox.container.background,
	}

	-- Second: music indicator
	local music = wibox.widget {{
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = 5,
				widgets.music,
			},
			top = 5,
			bottom = 5,
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		},
		shape = s.bar.shape,
		bg = beautiful.wibar_bg,
		widget = wibox.container.background,
	}

	-- Third: other stuff (time, layout, etc)
	local right_bar = wibox.widget {{
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
			layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				widgets.systray,
				widgets.ram_bar,
				widgets.time,
				widgets.layout
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}},
		shape = s.bar.shape,
		bg = beautiful.wibar_bg,
		widget = wibox.container.background,
	}

	s.bar:setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{ -- First bar
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				workspaces,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{ -- Second
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				music,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{ -- Third
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				right_bar,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}
	}
end)
