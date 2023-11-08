local compositor = require 'modules.compositor'
local M = {
	toggle = true
}

-- @return boolean state of the setting (on or off)
function M.toggle()
	return compositor.toggle()
end

function M.enabled()
	return compositor.running
end

function M.status()
	return compositor.running, 'Compositor'
end

return M
