local awful = require 'awful'
local beautiful = require 'beautiful'
local sounds = {
	notification = 'notify1.wav',
}

local M = {}
function M.play(s)
	awful.spawn.easy_async(string.format('pacat --property=media.role=event %s', beautiful.config_path .. 'sounds/' .. sounds[s]), function() end)
end

function M.notify()
	M.play 'notification'
end

return M
