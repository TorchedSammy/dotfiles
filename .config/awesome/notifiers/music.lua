local playerctl = require 'modules.playerctl'
local gears = require 'gears'
local naughty = require 'naughty'
local widgets = require 'ui.widgets'

playerctl.listenMetadata(function(title, artist, art)
	--[[
	naughty.notification {
		title = 'Now Playing\n' .. title,
		text = artist,
		icon = art,
		category = 'system.playerctl'
	}
	]]--
end)
