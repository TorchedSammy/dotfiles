local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local taglist = require 'ui.taglist'
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require('ui.widgets')

screen.connect_signal("property::geometry", helpers.set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	s.bar = awful.wibar({
		screen = s,
		position = "bottom",
		height = beautiful.wibar_height,
		bg = beautiful.wibar_bg
	})

	-- Add widgets to the wibox
	s.bar:setup {
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				widgets.ram_bar,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{ -- Middle widget
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				taglist(s),
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}, -- Middle widget
		{
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				widgets.music,
				widgets.volume_bar,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
	}
end)
-- }}}
