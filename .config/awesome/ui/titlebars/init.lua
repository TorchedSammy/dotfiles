local awful = require 'awful'
local beautiful = require 'beautiful'
local helpers = require 'helpers'
local wibox = require 'wibox'

if beautiful.titlebar_type == 'none' or not beautiful.titlebars then return end

client.connect_signal('request::titlebars', function(c)
	if c.requests_no_titlebar then
		return
	end

	local titlebar = require('ui.titlebars.' .. (beautiful.titlebar_type and beautiful.titlebar_type or 'default'))
	local tb = awful.titlebar(c, {size = beautiful.titlebar_height})
	tb:setup(titlebar(c))

	awesome.connect_signal('makeup::put_on', function(oldTheme)
		helpers.transitionColor {
			old = oldTheme.titlebar_bg,
			new = beautiful.titlebar_bg,
			transformer = function(c) tb:set_bg(c) end
		}
	end)
end)
