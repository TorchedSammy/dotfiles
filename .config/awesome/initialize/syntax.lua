local beautiful = require 'beautiful'
local awful = require 'awful'
local gears = require 'gears'
local caps = require 'modules.caps'
local music = require 'ui.panels.musicDisplay'
require 'ui.extras.syntax'

local music = music.create {
	placement = awful.placement.under_mouse,
	bg = beautiful.bg_sec
}
globalkeys = gears.table.join(globalkeys,
	awful.key({modkey}, 'x', function()
		music:toggle()
	end),
	awful.key({modkey}, 'q', function()
		--powerMenu.toggle()
	end)
)

root.keys(globalkeys)
