local awful = require 'awful'
local wibox = require 'wibox'
local base = require 'ui.components.syntax.base'

return function()
	local yes = wibox.widget {
		widget = wibox.widget.textbox,
		text = 'YEP'
	}
	local no = wibox.widget {
		widget = wibox.widget.textbox,
		text = 'NO'
	}

	awful.popup {
		widget = {
			layout = wibox.layout.align.vertical,
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = 5,
				yes,
				no,
			},
			base.sideDecor {
				h = 180,
				position = 'right'
			}
		},
		placement = awful.placement.centered
	}
end
