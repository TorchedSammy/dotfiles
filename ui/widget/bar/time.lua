local wibox = require 'wibox'
local beautiful = require 'beautiful'

return wibox.widget {
	layout = wibox.layout.align.vertical,
	{
		layout = wibox.container.place,
		halign = 'right',
		{
			widget = wibox.widget.textclock,
			format = '%-I:%M %p',
			font = beautiful.fontName .. ' 10'
		}
	},
	{
		widget = wibox.widget.textclock,
		format = '%a, %e %B',
		font = beautiful.fontName .. ' Bold 8'
	}
}
