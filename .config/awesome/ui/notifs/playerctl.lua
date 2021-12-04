local gears = require 'gears'
local naughty = require 'naughty'
local widgets = require 'ui.widgets'

awesome.connect_signal('bling::playerctl::title_artist_album',
function (title, artist, art)
	naughty.notify {
		title = 'Now Playing\n' .. title,
		text = artist,
		icon = gears.surface.load_uncached_silently(art)
	}
	local text = (artist and artist .. ' - ' or '') .. title
	widgets.music_name:set_markup_silently(gears.string.xml_escape(text))
end)

awesome.connect_signal('bling::playerctl::no_players', function()
	naughty.notify {
		title = 'Party\'s Over!',
		text = 'No more music playing.'
	}
	widgets.music_name:set_markup_silently 'Nothing Playing'
end)

