local gears = require 'gears'

local M = {
	held = false,
	holding = nil,
	holdingPanel = false
}

M.timer = gears.timer {
	timeout = 10,
	autostart = false,
	callback = function()
		M.held = false
	end
}

function M.hold(obj, isPanel)
	M.timer:start()
end

return M
