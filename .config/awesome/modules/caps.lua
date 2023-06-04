local awful = require 'awful'
local M = {}

--- Returns the state of caps lock
--- (whether it is enabled or not)
function M.state(cb)
	awful.spawn.easy_async_with_shell('cat /sys/class/leds/input3::capslock/brightness', function(out)
		local res = out:gsub('\n', '')
		cb(res == '1')
	end)
end

return M
