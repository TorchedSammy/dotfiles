local awful = require 'awful'
local base = require 'ui.components.syntax.base'
local common = require 'awful.widget.common'
local wibox = require 'wibox'
local gears = require 'gears'
local beautiful = require 'beautiful'
local taglist = require 'ui.taglist-modern'
local w = require 'ui.widgets.syntax'
local widgets = require 'ui.widgets'
local helpers = require 'helpers'
screen.connect_signal('property::geometry', helpers.set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	s.bar = awful.wibar({
		screen = s,
		position = 'bottom',
		height = beautiful.wibar_height,
		width = s.geometry.width,
		bg = '#00000000'
	})

	s.topbar = awful.wibar {
		screen = s,
		position = 'top',
		height = beautiful.topbar_height ,
		width = s.geometry.width,
		bg = '#00000000'
	}

	local tasklist_buttons = gears.table.join(
		awful.button({}, 1, function (c)
			if c == client.focus then
				c.minimized = true
			else
				c:emit_signal('request::activate', 'tasklist', {
					raise = true
				})
			end
		end),

		awful.button({}, 3, function()
			awful.menu.client_list({ theme = { width = 250 } })
		end),

		awful.button({}, 4, function()
			awful.client.focus.byidx(1)
		end),

		awful.button({}, 5, function()
			awful.client.focus.byidx(-1)
		end)
	)

	local height = beautiful.topbar_height - beautiful.dpi(10)
	local infoWidth = s.topbar.width / 9

	local function taskUpdate(widget, buttons, label, data, objects, args)
		common.list_update(widget, buttons, label, data, objects, args)
		widget:set_max_widget_size(beautiful.dpi(250))
	end

	s.tasklist = awful.widget.tasklist {
		screen   = s,
		filter   = awful.widget.tasklist.filter.currenttags,
		buttons  = tasklist_buttons,
		style = {
			shape = base.shape,
			shape_border_color = beautiful.fg_sec,
			shape_border_width = 1,
			fg_normal = beautiful.fg_sec
		},
		layout   = {
			spacing = beautiful.dpi(10),
			layout  = wibox.layout.flex.horizontal
		},
		widget_template = {
			{
				{
					{
						layout = wibox.container.place,
						halign = 'center',
						valign = 'center',
						{
							id     = 'text_role',
							widget = wibox.widget.textbox,
						}
					},
					left  = 10, right = 10,
					widget = wibox.container.margin
				},
				id     = 'background_role',
				widget = wibox.container.background,
			},
			widget = wibox.container.margin,
			left = beautiful.topbar_height / 10,
			top = beautiful.topbar_height / 10,
			bottom = (beautiful.topbar_height - height) + beautiful.topbar_height / 10,
		},
		update_function = taskUpdate
	}

	local infoAccentHeight = height + beautiful.dpi(4)
	local infoAccentGradient = base.createGradient(nil, infoAccentHeight, nil, 1)
	local infoAccent = base.gradientSurface {
		gradient = infoAccentGradient,
		w = infoWidth,
		h = infoAccentHeight
	}

	local realInfoDiff = beautiful.dpi(16)
	local realInfoWidth = infoWidth - realInfoDiff
	local imgspace = beautiful.dpi(12)
	local info = wibox.widget {
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			{
				widget = wibox.container.margin,
				left = imgspace,
				right = imgspace,
				{
					widget = wibox.container.margin,
					top = beautiful.dpi(10), bottom = beautiful.dpi(10 + math.sqrt(realInfoDiff)),
					widgets.imgwidget(gears.color.recolor_image(beautiful.config_path .. '/images/gradient-logo.svg', base.createGradient(1, 36, 0.2)))
				}
			},
			{
				widget = wibox.widget.separator,
				forced_width = 2,
				thickness = 2,
				orientation = 'vertical',
				color = beautiful.bg_sec_opposite
			},
		},
		{
			widget = wibox.container.place,
			halign = 'center',
			valign = 'center',
			{
				layout = wibox.layout.fixed.horizontal,
				{
					-- time
					widget = wibox.widget.textclock,
					format = helpers.colorize_text('%-I:%M ', beautiful.fg_normal_opposite),
				},
				{
					-- format in cyan
					widget = wibox.widget.textclock,
					format = helpers.colorize_text('%p', beautiful.xcolor6),
				}
			}
		}
	}

	local infoBarGradient = gears.color.create_pattern {
		type  = 'linear' ,
		from  = { 0, 0  },
		to    = { realInfoWidth, 1},
		stops = {
			{ 0.4, beautiful.bg_normal_opposite },
			{ 1, beautiful.bg_tert_opposite }
		}
	}
	local infoBarImg = base.gradientSurface {
		gradient = infoBarGradient,
		w = realInfoWidth,
		h = beautiful.topbar_height
	}

	local infoBar = wibox.widget {
		layout = wibox.layout.align.horizontal,
		{
			widget = wibox.container.margin,
			left = s.topbar.width - infoWidth,
			{
				layout = wibox.layout.stack,
				{
					{
						markup = '',
						widget = wibox.widget.textbox
					},
					shape = function(cr, wi, _) return gears.shape.partially_rounded_rect(cr, wi, infoAccentHeight, false, false, false, true, base.radius) end,
					bgimage = infoAccent,
					widget = wibox.container.background,
					forced_width = infoWidth,
					forced_height = infoAccentHeight
				},
				{
					widget = wibox.container.margin,
					left = realInfoDiff,
					{
						info,
						shape = function(cr, _, h) return gears.shape.partially_rounded_rect(cr, realInfoWidth, h, false, false, false, true, base.radius) end,
						bgimage = infoBarImg,
						widget = wibox.container.background,
						forced_width = realInfoWidth,
					}
				}
			}
		}
	}
	local realTop = wibox.widget {
		layout = wibox.layout.align.horizontal,
		{
			{
				layout = wibox.container.place,
				halign = 'center',
				valign = 'center',
				{
					markup = '',
					widget = wibox.widget.textbox
				}
			},
			shape = gears.shape.rectangle,
			bg = '#00000000',
			widget = wibox.container.background,
			forced_width = s.topbar.width / 10,
		},
		{
			layout = wibox.layout.stack,
			base.sideDecor {
				h = height,
				enforceHeight = true
			},
			{
				widget = wibox.container.margin,
				left = base.widths.round / 2,
				{
					{
						widget = wibox.container.margin,
						right = base.widths.round / 2,
						s.tasklist
					},
					shape = function(cr, wi, _) return gears.shape.rectangle(cr, wi, height) end,
					bg = beautiful.bg_normal,
					widget = wibox.container.background,
					forced_width = s.bar.width,
					forced_height = height
				}
			}
		}
	}

	local logoBtn = widgets.imgwidget(gears.color.recolor_image(beautiful.config_path .. '/images/gradient-logo.svg', beautiful.fg_tert))
	logoBtn.buttons = {
		awful.button({}, 1, function()
			w.startMenu.toggle()
		end)
	}
	helpers.displayClickable(logoBtn)

	local realbar = wibox.widget {
		layout = wibox.layout.ratio.horizontal,
		{
			{
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.wibar_spacing,
					logoBtn,
					{
						taglist(s),
						widget = wibox.container.background,
						shape = gears.shape.rounded_bar,
						bg = beautiful.bg_sec_opposite
					}
				},
				left = beautiful.dpi(24),
				right = beautiful.dpi(24),
				top = beautiful.dpi(6), bottom = beautiful.dpi(6),
				widget = wibox.container.margin
			},
			shape = gears.shape.rectangle,
			bg = beautiful.bg_tert_opposite,
			widget = wibox.container.background,
			forced_width = s.bar.width,
			forced_height = s.bar.height,
		},
		{
			{
				{
					layout = wibox.layout.align.horizontal,
					expand = 'none',
					{
						layout = wibox.layout.fixed.horizontal,
					},
					{
						layout = wibox.layout.fixed.horizontal,
					},
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.wibar_spacing,
						widgets.systray,
						widgets.layout
					}
				},
				left = beautiful.wibar_spacing,
				right = beautiful.wibar_spacing,
				widget = wibox.container.margin
			},
			shape = gears.shape.rectangle,
			bg = beautiful.bg_normal_opposite,
			widget = wibox.container.background,
			forced_width = s.bar.width,
			forced_height = s.bar.height,
		},
	}
	realbar:ajust_ratio(1, 0, 0.32, 0.68)

	s.bar:setup {
		layout = wibox.layout.align.horizontal,
		realbar
	}
	s.topbar:setup {
		layout = wibox.layout.stack,
		{
			widget = wibox.container.margin,
			right = infoWidth - beautiful.dpi(2),
			realTop,
		},
		infoBar
	}
end)

