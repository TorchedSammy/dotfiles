local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local wibox = require 'wibox'
local widgets = require 'ui.widgets'

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

	local close = widgets.button('close', {
		onClick = function() c:kill() end,
		size = beautiful.dpi(20)
	})

	local maximize

	maximize = widgets.button('expand-less', {
		onClick = function() 
			helpers.maximize(c)
		end,
		size = beautiful.dpi(20)
	})

	local function maximizeIcon()
		local valid = pcall(function() return c.valid end) and c.valid
		if not valid then return end

		return c.maximized and 'expand-less' or 'expand-more'
	end
	maximizeIcon()
	client.connect_signal('property::maximized', maximizeIcon)

	local minimize = widgets.button('minimize', {
		onClick = function()
			helpers.minimize(c)
		end,
		size = beautiful.dpi(20)
	})

	local spacing = beautiful.dpi(8)
	return {
		widget = wibox.container.margin,
		left = spacing,
		right = spacing,
		{
			layout = wibox.layout.align.horizontal,
			{
				widget = wibox.container.place,
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = spacing,
					buttons = buttons,
					{
						widget = wibox.container.constraint,
						strategy = 'exact',
						width = beautiful.dpi(25),
						awful.titlebar.widget.iconwidget(c),
					},
					{
						widget = awful.titlebar.widget.titlewidget(c),
						font = beautiful.fontName .. ' Medium 12',
					}
				}
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
	}
end

