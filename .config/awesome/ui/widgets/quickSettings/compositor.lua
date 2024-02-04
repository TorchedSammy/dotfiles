local compositor = require 'modules.compositor'
local util = require 'ui.widgets.quickSettings.util'

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

awesome.connect_signal('compositor::off', function()
	util.emitSignal('compositor', 'toggle', false)
end)

awesome.connect_signal('compositor::on', function()
	util.emitSignal('compositor', 'toggle', true)
end)

return M
