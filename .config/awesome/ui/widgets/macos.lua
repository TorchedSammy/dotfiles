local awful = require 'awful'
local beautiful = require 'beautiful'
local dpi = beautiful.dpi
local gears = require 'gears'
local helpers = require 'helpers'
local naughty = require 'naughty'
local wibox = require 'wibox'

local widgets = {}

widgets.volumeDisplay = function()
	local volumeDisplay = wibox {
		width = dpi(250),
		height = dpi(250),
		bg = beautiful.bg_normal,
		shape = helpers.rrect(5),
		ontop = true,
		visible = false
	}

	local volIcon = wibox.widget {
		text = '',
		font = 'Microns 80',
		align = 'center',
		widget = wibox.widget.textbox,
	}

	local volInfo = wibox.widget {
		font = 'SF Pro Text Medium 50',
		widget = wibox.widget.textbox
	}

	local displayTimer = gears.timer {
		timeout = 2,
		callback = function()
			volumeDisplay.visible = false
		end
	}

	volumeDisplay:setup {
		layout = wibox.container.place,
		valign = 'center',
		{
			layout = wibox.layout.fixed.vertical,
			volIcon,
			volInfo
		}
	}

	awesome.connect_signal('evil::volume', function(volume, mute)
		if volumeDisplay.visible then
			displayTimer:stop()
		end
		displayTimer:start()
		volInfo.text = tostring(volume) .. '%'

		awful.placement.bottom(volumeDisplay, { margins = { bottom = 200 }, parent = awful.screen.focused() })
		volumeDisplay.visible = true
	end)
end

return widgets
