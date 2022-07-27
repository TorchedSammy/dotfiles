local mp = require 'mp'
local shuffled = false

mp.register_script_message('shuffle', function()
	if not shuffled then
		mp.command 'playlist-shuffle'
	else
		mp.command 'playlist-unshuffle'
	end
	shuffled = not shuffled
	mp.set_property_bool('shuffle', shuffled)
end)

mp.register_script_message('volume', function()
	mp.command('script-message volumestat ' .. mp.get_property 'volume')
end)
