local awful = require 'awful'
local beautiful = require 'beautiful'
local helpers = require 'helpers'
local taglist = require 'ui.taglist-stardew'
local widgets = require 'ui.widgets'
local swidgets = require 'ui.widgets.stardew'
local wibox = require 'wibox'
local xresources = require 'beautiful.xresources'
local dpi = xresources.apply_dpi

screen.connect_signal('property::geometry', helpers.set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	swidgets.stardew_time(s)

--[[
	local musicbuttons = {
		widgets.imgwidget('icons/rightarrow.png'),
		layout = wibox.layout.fixed.horizontal
	}
]]--

	-- Create the wibox
	s.bar = awful.wibar {
		screen = s,
		position = 'top',
		height = beautiful.wibar_height,
		width = s.geometry.width - 22,
		shape = helpers.rrect(2),
		bg = '#00000000',
	}

	s.bar.y = beautiful.dpi(8)

	local streak = wibox.widget {
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
		},
		shape = s.bar.shape,
		bg = '#ede0d8' .. '99',
		widget = wibox.container.background,
		forced_width = s.bar.width,
	}

	local bg = wibox.widget {
		{
			-- doesnt work without this, idk
			layout = wibox.layout.align.horizontal,
			expand = 'none',
		},
		shape = s.bar.shape,
		bg = beautiful.wibar_bg,
		widget = wibox.container.background,
		shape_border_color = beautiful.border_normal,
		shape_border_width = 3,
		forced_width = s.bar.width,
		forced_height = s.bar.height,
	}

	local realbar = wibox.widget {
		layout = wibox.layout.stack,
		bg,
		{
			widget = wibox.container.margin,
			top = dpi(12),
			bottom = dpi(12),
			left = dpi(4),
			right = dpi(4),
			--streak
		},
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			{
				{
					layout = wibox.layout.fixed.horizontal,
				},
				left = beautiful.wibar_spacing,
				right = beautiful.wibar_spacing,
				widget = wibox.container.margin,
			},
			{
				{ -- Middle widgets
					layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.wibar_spacing,
					widgets.music,
			--		musicbuttons
				},
				left = beautiful.wibar_spacing,
				right = beautiful.wibar_spacing,
				widget = wibox.container.margin,
			},
			{
				{ -- Right widgets
					layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.wibar_spacing,
				},
				left = beautiful.wibar_spacing,
				right = beautiful.wibar_spacing,
				widget = wibox.container.margin,
			},
		},
	}

	local widgetsover = wibox.widget {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
				layout = wibox.layout.fixed.horizontal,
				taglist(s)
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,

		},
		{
			{ -- Middle widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				{
					{
						--widgets.volslider,
						widget = wibox.container.margin,
						left = dpi(8),
						right = dpi(8)
					},
					widget = wibox.container.background,
					shape = helpers.rrect(2),
					shape_border_color = beautiful.border_focus,
					shape_border_width = 3,
					bg = beautiful.bg_sec
				},
				widgets.layout(s),
				widgets.systray
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
	}

	s.bar:setup {
		layout = wibox.layout.stack,
		expand = 'none',
		{
			widget = wibox.container.margin,
			top = dpi(3),
			bottom = dpi(3),
			realbar
		},
		widgetsover
	}
end)
-- }}}
