local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty'
local widgets = require 'ui.widgets'
local bling = require 'libs.bling'

local playerctl = bling.signal.playerctl.lib()
local lastTitle
local lastArtist

local metadataCallbacks = {}

playerctl:connect_signal('metadata', function (_, title, artist, art, album)
	if title == lastTile and artist == lastArtist then return end

	local albumArt = gears.surface.load_uncached_silently(art, beautiful.config_path .. '/images/albumPlaceholder.png')
	for _, func in ipairs(metadataCallbacks) do
		func(gears.string.xml_unescape(title), gears.string.xml_unescape(artist), albumArt, gears.string.xml_unescape(album))
	end
end)

playerctl:connect_signal('no_players', function()
	naughty.notify {
		title = 'Party\'s Over!',
		text = 'No more music playing.'
	}
	widgets.music_name:set_markup_silently 'Nothing Playing'
end)

local M = {}

function M.listenMetadata(cb)
	table.insert(metadataCallbacks, cb)
end

return M
