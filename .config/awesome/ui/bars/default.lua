-- Bottom Bar inspired by woolenkitten
local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local text_taglist = require("taglist")
local widgets = require('widgets')
local helpers = require('helpers')
screen.connect_signal("property::geometry", helpers.set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	s.bar = awful.wibar({
		screen = s,
		position = "bottom",
		height = beautiful.wibar_height,
		width = s.geometry.width - 28,
		shape = gears.shape.rounded_bar,
		bg = "#00000000"
	})

	s.bar.y = s.geometry.height-36

	local realbar = wibox.widget {{
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{
			{
				layout = wibox.layout.fixed.horizontal,
				text_taglist(s)	
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,

		},
		{
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				widgets.music,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{ -- Right widgets
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
		},
		},
		shape = s.bar.shape,
		bg = beautiful.wibar_bg,
		widget = wibox.container.background,
		forced_width = s.geometry.width
	}

	s.bar:setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				realbar,
			},
			left = 1, right = 1,
			widget = wibox.container.margin,
		}
	}
end)

