local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty'
local helpers = require 'helpers'
local wibox = require 'wibox'

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

return function(c)
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

	local close = titlebarbtn(c, beautiful.xforeground, beautiful.xforeground .. 55, '')
	close:connect_signal('button::press', function()
		c:kill()
	end)

	local minimize = titlebarbtn(c, beautiful.xforeground, beautiful.xforeground .. 55, '')
	minimize:connect_signal('button::press', function()
		c.minimized = true
	end)

	local function maximizeIcon()
		if c.maximized then
			return ''
		else
			return ''
		end
	end

	local maximize = titlebarbtn(c, beautiful.xforeground, beautiful.xforeground .. 55, maximizeIcon())
	local function maximizeSetup()
		maximize.icon = maximizeIcon()
		helpers.maximize(c)
		maximize:emit_signal 'widget::redraw_needed'
	end
	maximize:connect_signal('button::press', maximizeSetup)

	return {
		layout = wibox.layout.align.horizontal,
		{
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
			buttons = buttons,
		},
		{
			{
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
				minimize,
				maximize,
				close,
				layout = wibox.layout.fixed.horizontal,
				spacing = 5,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}
	}
end

