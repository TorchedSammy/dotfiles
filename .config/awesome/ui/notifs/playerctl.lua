local gears = require 'gears'
local naughty = require 'naughty'
local widgets = require 'ui.widgets'
local bling = require 'modules.bling'

local playerctl = bling.signal.playerctl.lib()
playerctl:connect_signal('metadata', function (_, title, artist, art)
	naughty.notify {
		title = 'Now Playing\n' .. gears.string.xml_unescape(title),
		text = artist,
		icon = gears.surface.load_uncached_silently(art)
	}
	local text = (artist and artist .. ' - ' or '') .. title
	widgets.music_name:set_markup_silently(text)
end)

playerctl:connect_signal('no_players', function()
	naughty.notify {
		title = 'Party\'s Over!',
		text = 'No more music playing.'
	}
	widgets.music_name:set_markup_silently 'Nothing Playing'
end)

