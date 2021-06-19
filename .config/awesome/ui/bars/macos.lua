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

screen.connect_signal('property::geometry', helpers.set_wallpaper)

client.connect_signal('focus', function ()
	local fc = client.focus
	local name = ''

	if fc.class ~= 'Google-chrome' then
		local function titlecase(first, rest)
			return first:upper() .. rest:lower()
		end
		name = fc.class:gsub('[%-|%_]', ' '):gsub('(%a)([%w_\']*)', titlecase)
	else
		name = 'Chrome'
	end

	fc.screen.clientclass.text = name
end)

awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	awful.tag.attached_connect_signal(s, 'property::selected', function (t)
		indicate_icons = {'❶', '❷', '❸', '❹', '❺', '❻', '❼', '❽', '❾'}
		t.screen.workspace_indicate.text = indicate_icons[t.index]
		fc = client.focus
		if not fc then t.screen.clientclass.text = 'AwesomeWM' end
	end)
	local mainmenu = wibox.widget{
		{
			{
				markup = helpers.colorize_text('', beautiful.fg_normal),
				font = 'Font Awesome 13',
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
		position = 'top',
		height = beautiful.wibar_height,
		bg = beautiful.wibar_bg .. 'BF'
	}
	s.clientclass = wibox.widget {
		text = 'AwesomeWM',
		font = 'SF Pro Display Bold',
		widget = wibox.widget.textbox
	}
	s.workspace_indicate = wibox.widget {
		text = '❶',
		font = 'SF Pro Display Regular',
		widget = wibox.widget.textbox
	}

	s.bar:setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				mainmenu,
				{
					s.clientclass,
					top = beautiful.dpi(2),
					left = beautiful.dpi(7),
					widget = wibox.container.margin
				}
			},
			left = beautiful.dpi(15),
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				widgets.systray,
				s.workspace_indicate,
				widgets.macos_date,
				widgets.macos_time,
				widgets.layout
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
	}
end)
-- }}}
