local wibox = require 'wibox'
local awful = require 'awful'
local gears = require 'gears'
local beautiful = require 'beautiful'

local widgets = {}

widgets.battery = require 'ui.widgets.battery'
widgets.button = require 'ui.widgets.button'
widgets.icon = require 'ui.widgets.icon'
widgets.switch = require 'ui.widgets.switch'
widgets.systray = require 'ui.widgets.systray'
widgets.textbox = require 'ui.widgets.textbox'
widgets.textclock = wibox.widget.textclock '%-I:%M %p'
widgets.volume = require 'ui.widgets.volume'
widgets.wifi = require 'ui.widgets.wifi'

widgets.imgwidget = function(icon, args)
	args = args or {}
	local w = {
		image = type(icon) == 'string' and beautiful.config_path .. '/images/' .. icon or icon,
		widget = wibox.widget.imagebox
	}
	local wArgs = gears.table.join(w, args)

	local ico = wibox.widget(wArgs)

	return ico
end


function widgets.layout(s, size)
	local layoutbox = awful.widget.layoutbox(s)
	layoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end)
	))

	return {
		widget = wibox.container.constraint,
		width = size or beautiful.dpi(18),
		{
			widget = wibox.container.place,
			align = 'center',
			layoutbox
		}
	}
end

return widgets
