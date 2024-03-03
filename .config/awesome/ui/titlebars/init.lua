local awful = require 'awful'
local beautiful = require 'beautiful'
local wibox = require 'wibox'

if beautiful.titlebar_type == 'none' or not beautiful.titlebars then return end

client.connect_signal('request::titlebars', function(c)
	if c.requests_no_titlebar then
		return
	end

	local titlebar = require('ui.titlebars.' .. (beautiful.titlebar_type and beautiful.titlebar_type or 'default'))
	awful.titlebar(c, {size = beautiful.titlebar_height}):setup(titlebar(c))
end)
