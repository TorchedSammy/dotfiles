local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty'
local widgets = require 'ui.widgets'
local bling = require 'libs.bling'

local playerctl = bling.signal.playerctl.lib()
playerctl:connect_signal('metadata', function (_, title, artist, art)
	naughty.notification {
		title = 'Now Playing\n' .. gears.string.xml_unescape(title),
		text = gears.string.xml_unescape(artist),
		icon = gears.surface.load_uncached_silently(art, beautiful.config_path .. '/images/albumPlaceholder.png'),
		category = 'system.playerctl'
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

