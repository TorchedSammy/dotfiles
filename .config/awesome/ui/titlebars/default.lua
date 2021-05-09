local awful = require 'awful'
local wibox = require 'wibox'
local gears = require 'gears'

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

	awful.titlebar(c): setup {
		buttons = buttons,
		layout = wibox.layout.align.horizontal
	}
end)

