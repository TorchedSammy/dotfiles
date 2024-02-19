local awful = require 'awful'
local gears = require 'gears'
local M = {}

--- Returns the state of caps lock
--- (whether it is enabled or not)
function M.state(cb)
	awful.spawn.easy_async_with_shell('cat /sys/class/leds/input3::capslock/brightness', function(out)
		local res = out:gsub('\n', '')
		cb(res == '1')
	end)
end

globalkeys = gears.table.join(globalkeys,
	awful.key({}, 'Caps_Lock', function()
		gears.timer.start_new(0.3, function()
			M.state(function(state) awesome.emit_signal('caps::state', state) end)
		end)
	end)
)
root.keys(globalkeys)

return M
