local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty'
local widgets = require 'ui.widgets'
local bling = require 'libs.bling'

local M = {
	priority = {
		'Feishin',
		'cmus',
		'%any'
	}
}

local playerctl = bling.signal.playerctl.lib {
	player = M.priority,
	ignore = 'firefox'
--	update_on_activity = false -- TEMPORARY: exit signal doesnt work
}

local lastTitle
local lastArtist

local metadataCallbacks = {}
local metadata = {}
local players = {}
local activePlayer

local function indexOf(tbl, entry)
	local anyIdx
	for k, v in ipairs(tbl) do
		if v == '%any' then
			anyIdx = k
		end

		if v == entry then
			return k
		end
	end

	return anyIdx
end

local function dispatchMetadata(player)
	local data = metadata[player]
	local title = data.title
	local artist = data.artist
	local art = data.art
	local album = data.album

	for _, func in ipairs(metadataCallbacks) do
		func(title, artist, art, album)
	end
end

playerctl:connect_signal('metadata', function (_, title, artist, art, album, _new, player)

	if title == lastTile and artist == lastArtist then return end
	if not activePlayer then
		activePlayer = player
	end

	local priority = indexOf(M.priority, player)
	local curPlayerPriority = indexOf(M.priority, activePlayer)

	local t = gears.string.xml_unescape(title)
	local at = gears.string.xml_unescape(artist)
	local abm = gears.string.xml_unescape(album)
	local albumArt = art or beautiful.config_path .. '/images/albumPlaceholder.png'

	if not players[player] then
		players[player] = true
	end

	metadata[player] = {
		art = albumArt,
		title = t,
		artist = artist,
		album = album
	}

	if priority > curPlayerPriority then
		-- return
	else
		activePlayer = player
	end
	dispatchMetadata(player)
end)

playerctl:connect_signal('exit', function(_, player)
	naughty.notify {
		title = 'player exited',
		text = string.format('goodbye %s', player)
	}
	activePlayer = nil
	metadata[player] = nil
	players[player] = nil

	local priority = 1
	local nextPlayer
	for k, v in pairs(metadata) do
		local thisPriority = indexOf(k)
		if priority > thisPriority then
			priority = thisPriority
			nextPlayer = k
		end
	end
	
	dispatchMetadata(nextPlayer)
end)

playerctl:connect_signal('no_players', function()
	naughty.notify {
		title = 'Party\'s Over!',
		text = 'No more music playing.'
	}
	widgets.music_name:set_markup_silently 'Nothing Playing'
end)

function M.listenMetadata(cb)
	table.insert(metadataCallbacks, cb)
end

return M
