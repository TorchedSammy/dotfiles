local naughty = require 'naughty'
local widgets = require 'ui.widgets'

awesome.connect_signal('bling::playerctl::title_artist_album',
function (title, artist, art_path)
	naughty.notify {
		title = title,
		text = artist,
		image = art_path
	}
	widgets.music:set_markup_silently((artist and artist .. ' - ' or '') .. title)
end)

