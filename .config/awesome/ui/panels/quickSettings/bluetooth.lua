local bluetooth = require 'modules.bluetooth'

local M = {}

-- @return boolean state of the setting (on or off)
function M.toggle()
	return bluetooth.toggle()
end

function M.enabled()
	return bluetooth.enabled
end

function M.status()
	return bluetooth.enabled, 'Bluetooth'
end

return M
