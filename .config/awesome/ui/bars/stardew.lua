local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local naughty = require 'naughty'
local taglist = require 'ui.taglist-stardew'
local widgets = require 'ui.widgets'
local wibox = require 'wibox'
local xresources = require 'beautiful.xresources'
local dpi = xresources.apply_dpi
local vol = require 'conf.vol'

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

local volslider = wibox.widget {
	widget = wibox.widget.slider,
	value = 100,
	bar_shape = gears.shape.rounded_rect,
	bar_height = dpi(4),
	bar_color = beautiful.xforeground,
	bar_active_color = beautiful.xforeground,
	handle_color = beautiful.xforeground,
	handle_shape = gears.shape.circle,
	forced_width = 100,
}

-- get_volume_state returns the percent if its muted, we only take the percent part
vol.get_volume_state(function(volume)
	volslider.value = volume
end)

volslider:connect_signal('property::value', function()
	vol.set(volslider.value)
end)


local function imgwidget(icon)
	local ico = wibox.widget {
		image = gears.surface.load_uncached_silently(beautiful.config_path .. '/images/' .. icon),
		widget = wibox.widget.imagebox
	}

	return ico
end

awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	local stardew_time = wibox {
		width = dpi(200),
		height = dpi(100),
		bg = '#00000000',
		visible = true,
	}

	local seasonicon = imgwidget('stardew/season-winter.png')
	local weathericon = imgwidget('stardew/weather-snow.png')

	--[[
	-- we'll update the icons every hour
	gears.timer {
		timeout = 60 * 60, -- seconds * minutes (1 hour)
		autostart = true,
		call_now = true,
		callback = function()
			-- code
		end
	}
	]]--

	stardew_time:setup {
		imgwidget('stardew/daynightbig.png'),
		{
			{
				{
					{
						align = 'center',
						format = '%a. %d',
						font = 'SF Pro Text Medium 16',
						widget = wibox.widget.textclock,
					},
					top = dpi(5),
					widget = wibox.container.margin,
				},
				{
					-- line
					widget = wibox.widget.separator,
					color = beautiful.xforeground,
					forced_height = dpi(2),
					thickness = 2,
				},
				{
					{
						weathericon,
						imgwidget('stardew/clocksep.png'),
						seasonicon,
						layout = wibox.layout.fixed.horizontal,
					},
					widget = wibox.container.background,
					forced_height = dpi(33)
				},
				{
					-- line
					widget = wibox.widget.separator,
					color = beautiful.xforeground,
					forced_height = dpi(2),
					thickness = 2,
				},
				{
					align = 'center',
					format = '%-I:%M %P',
					font = 'SF Pro Text Medium 16',
					widget = wibox.widget.textclock,
				},
				layout = wibox.layout.fixed.vertical
			},
			bg = beautiful.wibar_bg,
			shape = helpers.rrect(2),
			shape_border_color = beautiful.xforeground,
			shape_border_width = 4,
			forced_width = stardew_time.width,
			forced_height = stardew_time.height,
			widget = wibox.container.background,
		},
		layout = wibox.layout.fixed.horizontal
	}
	stardew_time.visible = true
	awful.placement.top_right(stardew_time, { margins = { top = dpi(beautiful.wibar_height + 12), right = dpi(12) }, parent = s })

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
	local musicbuttons = {
		imgwidget('icons/rightarrow.png'),
		layout = wibox.layout.fixed.horizontal
	}

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

	local realbar = wibox.widget {{
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
				widgets.music,
				musicbuttons
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
						volslider,
						widget = wibox.container.margin,
						left = dpi(8),
						right = dpi(8)
					},
					widget = wibox.container.background,
					shape = helpers.rrect(2),
					shape_border_color = beautiful.xforeground,
					shape_border_width = 3,
					bg = beautiful.bg_sec
				},
				widgets.systray,
				--widgets.layout
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		},
		shape = s.bar.shape,
		bg = beautiful.wibar_bg,
		widget = wibox.container.background,
		shape_border_color = beautiful.xforeground,
		shape_border_width = 3,
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
			left = dpi(5), right = dpi(5),
			widget = wibox.container.margin,
		}
	}
end)
-- }}}
