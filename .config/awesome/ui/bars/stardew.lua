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

local function btn(icon)
	local ico = wibox.widget {
		image = gears.surface.load_uncached_silently(beautiful.config_path .. '/images/' .. icon),
		widget = wibox.widget.imagebox
	}

	return ico
end

awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	local stardew_time = wibox {
		width = dpi(150),
		height = dpi(100),
		bg = '#00000000',
		visible = true,
	}

	stardew_time:setup {
		{
			{
				{
					{
						widget = wibox.widget.textclock,
						format = '%-I:%M %P',
						font = 'SF Pro Text Medium 16',
						align = 'center',
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
					-- empty space
					widget = wibox.container.margin,
					top = dpi(33)
				},
				{
					-- line
					widget = wibox.widget.separator,
					color = beautiful.xforeground,
					forced_height = dpi(2),
					thickness = 2,
				},
				{
					widget = wibox.widget.textclock,
					font = 'SF Pro Text Medium 16',
					align = 'center',
					format = '%a %d',
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
		layout = wibox.layout.fixed.vertical
	}
	stardew_time.visible = true
	awful.placement.top_right(stardew_time, { margins = { top = dpi(beautiful.wibar_height + 12), right = dpi(10) }, parent = s })

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
		btn('icons/rightarrow.png'),
		layout = wibox.layout.fixed.horizontal
	}

	-- Create the wibox
	s.bar = awful.wibar {
		screen = s,
		position = 'top',
		height = beautiful.wibar_height,
		width = s.geometry.width - dpi(12),
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
			left = 1, right = 1,
			widget = wibox.container.margin,
		}
	}
end)
-- }}}
