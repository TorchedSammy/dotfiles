local awful = require 'awful'
local gears = require 'gears'
local widgets = require 'ui.widgets.syntax'
require 'ui.components.syntax'

local music = widgets.musicDisplay
local powerMenu = widgets.powerMenu
globalkeys = gears.table.join(globalkeys,
	awful.key({modkey}, 'x', function()
		music.toggle()
	end),
	awful.key({modkey}, 'q', function()
		powerMenu.toggle()
	end)
)

root.keys(globalkeys)
