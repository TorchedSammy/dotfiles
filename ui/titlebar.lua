local awful = require 'awful'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local util = require 'sys.util'
local button = require 'ui.widget.button'
local icon = require 'ui.widget.icon'

client.connect_signal('request::titlebars', function(c)
	if c.requests_no_titlebar then
		return
	end

	local close = button {
		icon = 'close'
	}

	local spacing = util.dpi(8)

	awful.titlebar(c, {
		height = util.dpi(beautiful.titlebarHeight),
		bg_normal = beautiful.titlebarBackground,
		bg_focus = beautiful.titlebarBackground
	}):setup {
		layout = wibox.container.margin,
		left = spacing, right = spacing,
		{
			layout = wibox.layout.align.horizontal,
			{
				widget = wibox.container.place,
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = spacing / 2,
					{
						widget = wibox.container.constraint,
						strategy = 'exact',
						width = util.dpi(22),
						awful.titlebar.widget.iconwidget(c),
					},
					{
						widget = awful.titlebar.widget.titlewidget(c),
						font = beautiful.fontName .. ' Medium 12',
					}
				}
			},
			nil,
			{
				layout = wibox.layout.fixed.horizontal,
				--minimize,
				--maximize,
				close
			}
		}
	}
end)
