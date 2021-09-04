local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty'
local helpers = require 'helpers'
local wibox = require 'wibox'

local function titlebarbtn(c, color_focus, color_unfocus, btn)
	local tb = wibox.widget {
		forced_width = beautiful.dpi(12),
		forced_height = beautiful.dpi(12),
		markup = helpers.colorize_text(btn, color_focus .. 80),
		widget = wibox.widget.textbox
	}

	local function update()
		if client.focus == c then
			tb.markup = helpers.colorize_text(btn, color_focus)
		else
			tb.markup = helpers.colorize_text(btn, color_unfocus)
		end
	end
	update()

	c:connect_signal('focus', update)
	c:connect_signal('unfocus', update)

	tb:connect_signal('mouse::enter', function()
		local clr = client.focus ~= c and color_focus or color_focus .. 55
		tb.markup = helpers.colorize_text(btn, clr)
	end)
	tb:connect_signal('mouse::leave', function()
		local clr = client.focus == c and color_focus or color_unfocus
		tb.markup = helpers.colorize_text(btn, clr)
	end)
	tb.visible = true
	return tb
end

function round_end(pos)
	local cors = {}
	if pos == 'top' then
		cors = {true, true, false, false}
	elseif pos == 'bottom' then
		cors = {false, false, true, true}
	end

	return function(cr, width, height, radius)
		gears.shape.partially_rounded_rect(cr, width, height, cors[1], cors[2], cors[3], cors[4], radius)
	end
end


local emptybar = function(pos, c)
		return wibox.widget {{
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.dpi(10),
			},
			left = beautiful.dpi(12),
			widget = wibox.container.margin,
		},
		{
			{
				layout = wibox.layout.flex.horizontal,
				spacing = beautiful.wibar_spacing
			},
			left = beautiful.wibar_spacing,
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
		},
		shape = round_end(pos),
		bg = beautiful.wibar_bg,
		widget = wibox.container.background,
		forced_width = c.screen.geometry.width,
	}
end

client.connect_signal('request::titlebars', function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal('request::activate', 'titlebar', {raise = true})
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal('request::activate', 'titlebar', {raise = true})
			awful.mouse.client.resize(c)
		end)
	)

	local close = titlebarbtn(c, beautiful.xcolor1, beautiful.xcolor8 .. 55, '✖')
	close:connect_signal('button::press', function()
		c:kill()
	end)

	--[[
	local minimize = titlebarbtn(c, beautiful.xcolor2, beautiful.xcolor8 .. 55, gears.shape.circle)
	minimize:connect_signal('button::press', function()
		c.minimized = true
	end)
	]]--

	local maximize = titlebarbtn(c, beautiful.xcolor3, beautiful.xcolor8 .. 55, '▭')
	maximize:connect_signal('button::press', function()
		helpers.maximize(c)
	end)

	local realbar = function(c)
		return {
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			{
				{
				layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.dpi(10),
				},
				left = beautiful.dpi(12),
				widget = wibox.container.margin,
			},
			{
				{
					{ -- Title
						align = 'center',
						widget = awful.titlebar.widget.titlewidget(c)
					},
					layout = wibox.layout.flex.horizontal,
					spacing = beautiful.wibar_spacing
				},
				left = beautiful.wibar_spacing,
				right = beautiful.wibar_spacing,
				widget = wibox.container.margin,
				buttons = buttons,
			},
			{
				{
			--		minimize,
			--		maximize,
					close,
					layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.wibar_spacing,
				},
				left = beautiful.wibar_spacing,
				right = beautiful.wibar_spacing,
				widget = wibox.container.margin,
				buttons = buttons,
			},
		},
		shape = round_end('top'),
		bg = beautiful.wibar_bg,
		widget = wibox.container.background,
		forced_width = c.screen.geometry.width,
	}
end

	awful.titlebar(c, {size = beautiful.titlebar_height, bg = '#00000000'}): setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		realbar(c)
	}
	awful.titlebar(c, {size = beautiful.dpi(12), bg = '#00000000', position = 'bottom'}): setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				emptybar('bottom', c)
			},
			widget = wibox.container.margin,
		}
	}

	client.connect_signal('property::size', function(c)
		awful.titlebar(c, {size = beautiful.titlebar_height, bg = '#00000000'}): setup {
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			realbar(c)
		}

		awful.titlebar(c, {size = beautiful.dpi(12), bg = '#00000000', position = 'bottom'}): setup {
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			{
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.wibar_spacing,
					emptybar('bottom', c)
				},
				widget = wibox.container.margin,
			}
		}
	end)
end)

