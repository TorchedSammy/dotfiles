local p = require 'dbus_proxy'
local proxy = p.Proxy:new {
	bus = p.Bus.SYSTEM,
	name = 'com.system76.Scheduler',
	interface = 'com.system76.Scheduler',
	path = '/com/system76/Scheduler'
}
local M = {}

function M.setForeground(pid)
	proxy:SetForegroundProcess(pid)
end

return M
