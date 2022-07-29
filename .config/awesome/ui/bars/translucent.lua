local awful = require 'awful'
local naughty = require 'naughty'
local wibox = require 'wibox'
local gears = require 'gears'
local beautiful = require 'beautiful'
local text_taglist = require 'ui.taglist'
local widgets = require 'ui.widgets'
local helpers = require 'helpers'
screen.connect_signal('property::geometry', helpers.set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	local function rect(cr, w, h)
		return gears.shape.rounded_rect(cr, w, h, 6)
	end

	s.bar = awful.wibar({
		screen = s,
		position = 'bottom',
		height = beautiful.wibar_height,
		width = s.geometry.width - (beautiful.useless_gap * 4),
		shape = rect,
		bg = '#00000000',
	})

	local function darkerRect(widget, w, h)
		return wibox.widget {
			{
				widget = wibox.container.margin,
				left = 10, right = 10,
				widget,
			},
			shape = rect,
			bg = beautiful.wibar_bg .. string.format('%02x', math.floor(0.6 * 255)),
			widget = wibox.container.background,
			forced_width = w or widget.forced_width,
			forced_height = h or w or widget.forced_height
		}
	end

	local realbar = wibox.widget {{
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
				layout = wibox.layout.fixed.horizontal,
				--text_taglist(s)
				darkerRect {
					widget = wibox.widget.textbox,
					text = '',
					font = 'Microns 16'
				}
			},
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{ -- Middle widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				--widgets.music,
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
				--widgets.ram_bar,
				darkerRect(widgets.time),
				darkerRect {
					widget = wibox.container.margin,
					top = 4, bottom = 4,
					widgets.layout
				}
			},
			left = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		},
		shape = s.bar.shape,
		-- string format converts number to hex, for transparency
		bg = beautiful.wibar_bg .. string.format('%02x', math.floor(0.75 * 255)),
		widget = wibox.container.background,
		forced_width = s.bar.width,
		forced_height = s.bar.height
	}

	s.bar:setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
				layout = wibox.layout.fixed.horizontal,
				realbar,
			},
			bottom = beautiful.useless_gap * 2,
			widget = wibox.container.margin,
		}
	}
end)

