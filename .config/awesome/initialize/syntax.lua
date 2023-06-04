local awful = require 'awful'
local gears = require 'gears'
local widgets = require 'ui.widgets.syntax'
local caps = require 'modules.caps'
require 'ui.components.syntax'

local music = widgets.musicDisplay
local powerMenu = widgets.powerMenu
globalkeys = gears.table.join(globalkeys,
	awful.key({modkey}, 'x', function()
		music.toggle()
	end),
	awful.key({modkey}, 'q', function()
		powerMenu.toggle()
	end),
	awful.key({}, 'Caps_Lock', function()
		gears.timer.start_new(0.2, function() caps.state(widgets.capsIndicator.display) end)
	end)
)

root.keys(globalkeys)
