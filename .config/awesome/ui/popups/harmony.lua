local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local wibox = require 'wibox'
local w = require 'ui.widgets'
local syntax = require 'ui.components.syntax'
local sfx = require 'modules.sfx'

local volumeDisplay = wibox {
	width = beautiful.dpi(420),
	height = beautiful.dpi(88),
	bg = '#00000000',
	ontop = true,
	visible = false,
}

local displayTimer = gears.timer {
	timeout = 1.5,
	single_shot = true,
	callback = function()
		volumeDisplay:off()
	end
}

local spacing = beautiful.dpi(16)
local volSlider = syntax.slider {
	width = volumeDisplay.width - beautiful.dpi(100) - (spacing * 2) - (beautiful.dpi(16) * 4),
	bg = beautiful.xcolor10,
	color = beautiful.accent,
	onChange = function(val)
		sfx.setVolume(val)
	end
}
local volPercent = wibox.widget {
	widget = wibox.widget.textbox,
	text = '0%',
	font = beautiful.fontName .. ' Bold 16'
}

local popupWidget = wibox.widget {
	widget = wibox.container.constraint,
	strategy = 'exact',
	width = volumeDisplay.width,
	height = volumeDisplay.height,
	{	
		widget = wibox.container.background,
		bg = beautiful.bg_sec,
		shape = helpers.rrect(beautiful.radius),
		{
			layout = wibox.layout.fixed.horizontal,
			{
				widget = wibox.container.constraint,
				strategy = 'exact',
				width = volumeDisplay.height,
				height = volumeDisplay.height,
				{
					widget = wibox.container.background,
					bg = beautiful.xcolor9,
					w.icon('volume', {
						size = beautiful.dpi(32)
					})
				}
			},
			{
				widget = wibox.container.margin,
				margins = spacing,
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = spacing,
					volSlider,
					volPercent
				}
			}
		}
	}
}

volumeDisplay:setup {
	layout = wibox.container.place,
	popupWidget
}

helpers.slidePlacement(volumeDisplay, {
	placement = 'bottom'
})

awesome.connect_signal('syntax::volume', function(volume, muted, init)
	if init then
		volSlider.value = volume
		volPercent.text = string.format('%s%%', volume)
		return
	end

	if volumeDisplay.visible then
		displayTimer:stop()
	end

	volumeDisplay:on()
	volSlider.value = volume
	volPercent.text = string.format('%s%%', volume)
	displayTimer:start()
end)
