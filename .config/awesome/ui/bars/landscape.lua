local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local text_taglist = require("taglist")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require('widgets')

local systray_margin = (beautiful.wibar_height-beautiful.systray_icon_size)/2

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	local l = awful.layout.suit
	local layouts = { l.floating, l.spiral.dwindle, l.floating, l.tile, l.floating, l.floating, l.floating, l.floating, l.floating }
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, layouts)


	s.bar = awful.wibar({
		screen = s,
		position = "bottom",
		height = beautiful.wibar_height,
		bg = beautiful.wibar_bg
	})
	s.topbar = awful.wibar({ screen = s, position = "top", height = beautiful.wibar_height, bg = beautiful.wibar_bg })

	s.topbar:setup {
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = 4,
				widgets.music_icon,
				widgets.music
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{ -- Middle widget
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}, -- Middle widget
		{
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				widgets.time,
				{
					s.mylayoutbox,
					top = 8, bottom = 8,
	        widget = wibox.container.margin
				}
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
	}

	-- Add widgets to the wibox
	s.bar:setup {
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				text_taglist(s),
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{ -- Middle widget
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				systraycontainer,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}, -- Middle widget
		{
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				widgets.ram_bar,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
	}

end)
-- }}}