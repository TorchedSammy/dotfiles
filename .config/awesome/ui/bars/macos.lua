local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local naughty = require 'naughty'
local taglist = require 'ui.taglist'
local widgets = require 'ui.widgets'
local wibox = require 'wibox'
local xresources = require 'beautiful.xresources'
local dpi = xresources.apply_dpi

clientclass = wibox.widget{
		text = "AwesomeWM",
		font = "SF Pro Display Bold",
		widget = wibox.widget.textbox
}
local workspace_indicate = wibox.widget {
		text = "❶",
		font = 'SF Pro Display Regular',
		widget = wibox.widget.textbox
}

screen.connect_signal("property::geometry", helpers.set_wallpaper)
client.connect_signal("focus", function ()
	fc = client.focus
	clientclass.text = fc.class
end)

awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	awful.tag.attached_connect_signal(s, 'property::selected', function (t)
		indicate_icons = {'❶', '❷', '❸', '❹', '❺', '❻', '❼', '❽', '❾'}
		workspace_indicate.text = indicate_icons[t.index]
		fc = client.focus
		if not fc then clientclass.text = "AwesomeWM" end
	end)
	local mainmenu = wibox.widget{
		{
			{
				markup = helpers.colorize_text("", beautiful.fg_normal),
				font = "Font Awesome 13",
				widget = wibox.widget.textbox
			},
			top = 4, bottom = 4, left = 6,
			widget = wibox.container.margin
		},
		widget = wibox.container.background,
		buttons = gears.table.join(
			awful.button({}, 1, function () mainmenu:toggle({ coords = {x = 0, y = s.geometry.height-beautiful.wibar_height}}) end))
	}

	-- Create the wibox
	s.bar = awful.wibar {
		screen = s,
		position = "top",
		height = beautiful.wibar_height,
		bg = beautiful.wibar_bg
	}

	-- Add widgets to the wibox
	s.bar:setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				mainmenu,
				{
					clientclass,
					left = 6,
					widget = wibox.container.margin
				}
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = beautiful.wibar_spacing,
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}, 
		{
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				widgets.ram_bar,
				workspace_indicate,
				widgets.systray,
				widgets.time,
				{
					widgets.layout,
					top = 8, bottom = 8,
					widget = wibox.container.margin
				}
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
	}

end)
-- }}}
