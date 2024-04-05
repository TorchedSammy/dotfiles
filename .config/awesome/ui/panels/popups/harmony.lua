local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local wibox = require 'wibox'
local w = require 'ui.widgets'
local syntax = require 'ui.components.syntax'
local sfx = require 'modules.sfx'
local caps = require 'modules.caps'

local volumeDisplay = helpers.aaWibox {
	width = beautiful.dpi(420),
	height = beautiful.dpi(88),
	bg = '#00000000',
	ontop = true,
	visible = false,
	rrectRadius = beautiful.radius,
	bg = beautiful.bg_sec,
}

local displayTimer = gears.timer {
	timeout = 1,
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

local capsLabel = wibox.widget {
	widget = wibox.widget.textbox,
	text = 'Caps Lock is Off',
	font = beautiful.fontName .. ' Bold 16'
}

local function createPopup(icon, layout)
	local icoWidget = w.icon(icon, {
		size = beautiful.dpi(32),
		color = beautiful.xcolor14
	})

	local popup = wibox.widget {
		widget = wibox.container.constraint,
		strategy = 'exact',
		width = volumeDisplay.width,
		height = volumeDisplay.height,
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
						icoWidget
					}
				},
				{
					widget = wibox.container.margin,
					margins = spacing,
					layout
				}
		}
	}

	return popup, icoWidget
end

local volumePopupWid, volumeIcon = createPopup('volume', wibox.widget {
	layout = wibox.layout.fixed.horizontal,
	spacing = spacing,
	volSlider,
	volPercent
})

local capsPopupWid, capsIcon = createPopup('caps-on', capsLabel)

volumeDisplay:setup {
	layout = wibox.container.place,
	volumePopupWid
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
	volumeDisplay:setup {
		layout = wibox.container.place,
		volumePopupWid
	}

	if volumeDisplay.visible then
		displayTimer:stop()
	end
	volumeDisplay:on()

	volumeIcon.icon = muted and 'volume-muted' or 'volume'
	volSlider.value = volume
	volSlider.color = muted and beautiful.xcolor12 or beautiful.accent
	volPercent.text = string.format('%s%%', volume)
	displayTimer:start()
end)

awesome.connect_signal('caps::state', function(state)
	volumeDisplay:setup {
		layout = wibox.container.place,
		capsPopupWid
	}

	if volumeDisplay.visible then
		displayTimer:stop()
	end
	volumeDisplay:on()

	capsIcon.icon = state and 'caps-on' or 'caps-off'
	capsLabel.text = state and 'Caps Lock is On' or 'Caps Lock is Off'

	displayTimer:start()
end)
