local awful = require 'awful'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local util = require 'sys.util'

client.connect_signal('request::titlebars', function(c)
	if c.requests_no_titlebar then
		return
	end

	awful.titlebar(c, {
		height = util.dpi(beautiful.titlebarHeight),
		bg_normal = beautiful.titlebarBackground,
		bg_focus = beautiful.titlebarBackground
	}):setup {
		layout = wibox.layout.align.horizontal,
		{
			layout = wibox.layout.fixed.horizontal,
			{
				widget = wibox.container.constraint,
				strategy = 'exact',
				width = util.dpi(25),
				awful.titlebar.widget.iconwidget(c),
			},
			{
				widget = awful.titlebar.widget.titlewidget(c),
				font = beautiful.fontName .. ' Medium 12',
			}
		},
	}
end)
