local awful = require 'awful'
local base = require 'ui.components.syntax.base'
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
	if c.requests_no_titlebar or c.class == 'mpv' then
		return
	end

	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal('request::activate', 'titlebar', {raise = true})
			awful.mouse.client.move(c)
		end)
	)

	local width = 6
	local rad = 6

	local gradientBar = wibox.widget {
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
		},
		shape = gears.shape.rectangle,
		bg = base.gradientColors[1],
		widget = wibox.container.background,
		forced_width = width
	}

	local logo = widgets.imgwidget 'grey-logo.png'
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

	local imgspace = 12
	local buttonsSection = wibox.widget {
		{
			widget = wibox.container.margin,
			left = (buttonsSectionW - imgspace) - (50 - imgspace),
			right = imgspace,
			{
				widget = wibox.container.margin,
				top = 2, bottom = 2,
				logo
			}
		},
		forced_width = buttonsSectionW,
		bgimage = buttonsImg,
		shape = function(cr, w, h) return gears.shape.partially_rounded_rect(cr, w, h, true, true, false, true, rad) end,
		widget = wibox.container.background
	}
	local tailwind = widgets.imgwidget(gears.color.recolor_image(beautiful.config_path .. '/images/tailwind.png', base.createGradient(1, 36, 0.2)))

	local empty = wibox.widget {
		{
			markup = '',
			widget = wibox.widget.textbox
		},
		shape = gears.shape.rectangle,
		bg = beautiful.titlebar_bg,
		widget = wibox.container.background,
		forced_width = c.width
	}

	local realbar = wibox.widget {
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
				bg = beautiful.titlebar_bg,
				widget = wibox.container.background,
				forced_width = c.width - beautiful.dpi(120),
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
						forced_width = 25
					},
					buttonsSection
				},
				{
					{
						markup = '',
						widget = wibox.widget.textbox
					},
					shape = function(cr, w, h) return gears.shape.partially_rounded_rect(cr, 24, h, false, true, false, false, 16) end,
					bg = beautiful.titlebar_bg,
					widget = wibox.container.background,
					forced_width = 20
				},
				tailwind,
			},
		},
	}

	awful.titlebar(c, {size = beautiful.titlebar_height, bg = '#00000000'}): setup {
		layout = wibox.layout.fixed.vertical,
		buttons = buttons,
		realbar
	}
end

client.connect_signal('request::titlebars', function(c)
	setupTitlebar(c)
end)

client.connect_signal('property::size', function(c)
	setupTitlebar(c)
end)

