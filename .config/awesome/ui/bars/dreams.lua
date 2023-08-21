local awful = require 'awful'
local wibox = require 'wibox'
local gears = require 'gears'
local beautiful = require 'beautiful'
local taglist = require 'ui.taglist-modern'
local widgets = require 'ui.widgets'
local helpers = require 'helpers'

local music = require 'ui.widgets.musicDisplay'
local musicWibox = music.create {
	bg = beautiful.bg_popup,
	placement = function(c)
		awful.placement.align(c, {
			position = 'top',
			margins = {
				top = beautiful.wibar_height + beautiful.useless_gap * beautiful.dpi(3)
			},
			parent = awful.screen.focused()
		})
	end
}

awful.screen.connect_for_each_screen(function(s)
	s.bar = awful.wibar({
		screen = s,
		position = 'top',
		height = beautiful.wibar_height,
		width = s.geometry.width,
		bg = '#00000000'
	})

	s.sidebar = awful.wibar({
		screen = s,
		position = 'left',
		width = beautiful.wibar_height,
		height = s.geometry.height - beautiful.wibar_height,
		bg = '#00000000'
	})

	local minimize = widgets.button('minimize', {
		bg = beautiful.bg_normal,
		-- size = btnSize,
		onClick = function() client.focus.minimized = true end
	})

	local maximize = widgets.button('expand-more', {
		bg = beautiful.bg_normal,
		-- size = btnSize,
		onClick = function() helpers.maximize(client.focus) end
	})

	local close = widgets.button('close', {
		bg = beautiful.bg_normal,
		-- size = btnSize,
		onClick = function() client.focus:close() end
	})
	
	local winControls = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		minimize,
		maximize,
		close
	}

	local music = widgets.music
	music.buttons = {
		awful.button({}, 1, function()
			musicWibox.toggle()
		end),
	}

	local bar = {
		--direction = 'east',
        widget = wibox.container.rotate,
        {
			widget = wibox.container.background,
			bg = beautiful.bg_normal,
			{
				layout = wibox.layout.align.horizontal,
				expand = 'none',
				{
					{ -- First bar
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.wibar_spacing,
						widgets.icon(beautiful.os_icon),
					},
					left = beautiful.wibar_spacing,
					right = beautiful.wibar_spacing,
					widget = wibox.container.margin,
				},
				{
					{ -- First bar
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.wibar_spacing,
						music,
					},
					left = beautiful.wibar_spacing,
					right = beautiful.wibar_spacing,
					widget = wibox.container.margin,
				},
				{
					{ -- First bar
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.wibar_spacing,
						winControls
					},
					left = beautiful.wibar_spacing,
					right = beautiful.wibar_spacing,
					widget = wibox.container.margin,
				},
			}
        }
	}

	local side = {
		widget = wibox.container.background,
		bg = beautiful.bg_normal,
		{
			layout = wibox.layout.align.vertical,
			expand = 'none',
			{
				{ -- First bar
					layout = wibox.layout.fixed.vertical,
					spacing = beautiful.wibar_spacing,
					taglist(s, true),
				},
				top = beautiful.wibar_spacing,
				bottom = beautiful.wibar_spacing,
				widget = wibox.container.margin,
			},
			{
				{ -- First bar
					layout = wibox.layout.fixed.vertical,
					spacing = beautiful.wibar_spacing,
				},
				top = beautiful.wibar_spacing,
				bottom = beautiful.wibar_spacing,
				widget = wibox.container.margin,
			},
			{
				{ -- First bar
					layout = wibox.layout.fixed.vertical,
					spacing = beautiful.wibar_spacing,
					widgets.icon 'battery',
					widgets.systray {
						bg = beautiful.bg_normal,
						vertical = true,
						bar = s.sidebar
					},
					widgets.layout(s)
				},
				top = beautiful.wibar_spacing,
				bottom = beautiful.wibar_spacing,
				widget = wibox.container.margin,
			},
		}
	}

	s.bar:setup(bar)
	s.sidebar:setup(side)
end)

