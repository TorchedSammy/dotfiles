local awful = require 'awful'
local base = require 'ui.extras.syntax.base'
local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty'
local helpers = require 'helpers'
local wibox = require 'wibox'
local widgets = require 'ui.widgets'
local cairo = require 'lgi'.cairo

local function circle(c, color_focus, color_unfocus, shp)
	local ico = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}
	local tb = wibox.widget {
		ico,
		forced_width = beautiful.dpi(16),
		forced_height = beautiful.dpi(16),
		bg = color_focus .. 80,
		shape = shp,
		widget = wibox.container.background
	}

	local function update()
		if client.focus == c then
				tb.bg = color_focus
		else
				tb.bg = color_unfocus
		end
	end
	update()

	c:connect_signal('focus', update)
	c:connect_signal('unfocus', update)

	tb:connect_signal('mouse::enter', function()
		local clr = client.focus ~= c and color_focus or color_focus .. 55
		tb.bg = clr
	end)
	tb:connect_signal('mouse::leave', function()
		local clr = client.focus == c and color_focus or color_unfocus
		tb.bg = clr
	end)

	tb.visible = true

	return tb
end

local function setupTitlebar(c)
	-- this seems confusing, but the value of this property is flipped to what
	-- it should actually be for some reason
	if c.requests_no_titlebar then
		return
	end

	local buttons = gears.table.join(
		awful.button({}, 1, function()
            c:activate { context = "titlebar", action = "mouse_move"  }
		end),
		awful.button({}, 3, function()
            c:activate { context = "titlebar", action = "mouse_resize"  }
		end)
	)

	local gradientBar = wibox.widget {
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
		},
		shape = gears.shape.rectangle,
		bg = base.gradientColors[1],
		widget = wibox.container.background,
		forced_width = base.width / 2
	}

	if c.class == 'mpv' then
		gradientBar = wibox.widget {
			widget = wibox.container.mirror,
			reflection = {
				vertical = true
			},
			base.sideDecor {
				h = beautiful.titlebar_height,
				noRounder = true,
			},
		}
	end

	local logo = widgets.imgwidget(gears.color.recolor_image(beautiful.config_path .. '/images/gradient-logo.svg', beautiful.fg_tert))
	local buttonsSectionW = beautiful.dpi(120)
	local buttonsGradient = gears.color.create_pattern {
		type  = "linear" ,
		from  = { 0, 0  },
		to    = { buttonsSectionW, 1},
		stops = {
			{ 0, beautiful.bg_tert_opposite },
			{ 1, beautiful.bg_normal_opposite }
		}
	}
	local buttonsImg = cairo.ImageSurface.create(cairo.Format.ARGB32, buttonsSectionW, beautiful.titlebar_height)
	local cr = cairo.Context(buttonsImg)
	cr:set_source(buttonsGradient)
	cr:paint()

	local function titlebarbtn(c, color_focus, color_unfocus, txt)
		local ico = wibox.widget {
			markup = helpers.colorize_text(txt, color_focus .. 80),
			font = 'Microns 16',
			widget = wibox.widget.textbox,
			icon = txt
		}

		local function update()
			if client.focus == c then
				ico.markup = helpers.colorize_text(ico.icon, color_focus)
			else
				ico.markup = helpers.colorize_text(ico.icon, color_unfocus)
			end
		end
		update()

		c:connect_signal('focus', update)
		c:connect_signal('unfocus', update)

		ico:connect_signal('mouse::enter', function()
			local clr = client.focus ~= c and color_focus or color_focus .. 55
			ico.markup = helpers.colorize_text(ico.icon, clr)
		end)
		ico:connect_signal('mouse::leave', function()
			local clr = client.focus == c and color_focus or color_unfocus
			ico.markup = helpers.colorize_text(ico.icon, clr)
		end)

		ico.visible = true
		return ico
	end
	local close = titlebarbtn(c, beautiful.fg_normal_opposite, beautiful.fg_normal_opposite .. 55, '')
	close:connect_signal('button::press', function()
		c:kill()
	end)

	local buttonsSection
	local minimize = titlebarbtn(c, beautiful.fg_normal_opposite, beautiful.fg_normal_opposite .. 55, '')
	minimize:connect_signal('button::press', function()
		c.minimized = true
		buttonsSection:emit_signal 'mouse::leave'
	end)

	local function maximizeIcon()
		if c.maximized then
			return ''
		else
			return ''
		end
	end

	local maximize = titlebarbtn(c, beautiful.fg_normal_opposite, beautiful.fg_normal_opposite .. 55, maximizeIcon())
	local function maximizeSetup()
		maximize.icon = maximizeIcon()
		helpers.maximize(c)
		maximize:emit_signal 'widget::redraw_needed'
	end
	maximize:connect_signal('button::press', maximizeSetup)
	local imgspace = beautiful.dpi(12)
	buttonsSection = wibox.widget {
		{
			widget = wibox.container.margin,
			left = (buttonsSectionW - imgspace) - beautiful.dpi(70),
			right = imgspace,
			{
				widget = wibox.container.margin,
				top = 2, bottom = 2,
				{
					layout = wibox.layout.stack,
					{
						widget = wibox.container.margin,
						left = beautiful.dpi(38),
						{
							widget = logo,
							id = 'logo'
						}
					},
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.dpi(4),
						visible = false,
						minimize,
						maximize,
						close,
						id = 'winControls'
					}
				}
			}
		},
		forced_width = buttonsSectionW,
		bgimage = buttonsImg,
		shape = function(cr, w, h) return gears.shape.partially_rounded_rect(cr, w, h, true, true, false, true, rad) end,
		widget = wibox.container.background
	}
	local tailwind = widgets.imgwidget(gears.color.recolor_image(beautiful.config_path .. '/images/tailwind.svg', base.createGradient(1, 36, 0.2)))
	buttonsSection:connect_signal('mouse::enter', function()
		local controls = buttonsSection:get_children_by_id 'winControls'[1]
		logo.visible = false
		controls.visible = true
		buttonsSection:emit_signal('widget::redraw_needed')
	end)
	buttonsSection:connect_signal('mouse::leave', function()
		local controls = buttonsSection:get_children_by_id 'winControls'[1]
		logo.visible = true
		controls.visible = false
		buttonsSection:emit_signal('widget::redraw_needed')
	end)

	local empty = wibox.widget {
		{
			markup = '',
			widget = wibox.widget.textbox
		},
		shape = gears.shape.rectangle,
		bg = beautiful.titlebar_bg_real,
		widget = wibox.container.background,
		forced_width = c.width
	}

	return {
		shape = gears.shape.rectangle,
		bg = '#00000000',
		widget = wibox.container.background,
		forced_width = c.width,
		{
			layout = wibox.layout.align.horizontal,
			gradientBar,
			{
				{
					markup = '',
					widget = wibox.widget.textbox
				},
				shape = gears.shape.rectangle,
				bg = beautiful.titlebar_bg_real,
				widget = wibox.container.background,
				forced_width = c.width - beautiful.dpi(120),
				buttons = buttons,
			},
			{
				layout = wibox.layout.stack,
				{
					layout = wibox.layout.fixed.horizontal,
					{
						{
							markup = '',
							widget = wibox.widget.textbox
						},
						shape = function(cr, w, h) return gears.shape.partially_rounded_rect(cr, w, h, false, false, true, true, 5) end,
						bg = '#00000000',
						widget = wibox.container.background,
						forced_width = beautiful.dpi(25)
					},
					buttonsSection
				},
				{
					{
						markup = '',
						widget = wibox.widget.textbox
					},
					shape = function(cr, w, h) return gears.shape.partially_rounded_rect(cr, beautiful.dpi(24), h, false, true, false, false, 16) end,
					bg = beautiful.titlebar_bg_real,
					widget = wibox.container.background,
					forced_width = beautiful.dpi(20),
				},
				tailwind,
			},
		},
	}
end

return setupTitlebar
