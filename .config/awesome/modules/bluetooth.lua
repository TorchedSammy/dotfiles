local lgi = require 'lgi'
local p = require 'dbus_proxy'

local adapter = p.Proxy:new {
	bus = p.Bus.SYSTEM,
	name = 'org.bluez',
	interface = 'org.bluez.Adapter1',
	path = '/org/bluez/hci0'
}
local objManager = p.Proxy:new {
	bus = p.Bus.SYSTEM,
	name = 'org.bluez',
	interface = 'org.freedesktop.DBus.ObjectManager',
	path = '/'
}

local M = {
	enabled = adapter.Powered
}

function M.toggle()
	local powered = adapter.Powered

	adapter:Set('org.bluez.Adapter1', 'Powered', lgi.GLib.Variant('b', not powered))
	adapter.Powered = {
		signature = 'b',
		value = not powered,
	}

	adapter:Set('org.bluez.Adapter1', 'Discoverable', lgi.GLib.Variant('b', true))
	adapter.Discoverable = {
		signature = 'b',
		value = true,
	}

	M.enabled = not powered

	return M.enabled
end

function M.scan()
	adapter:StartDiscovery()
end

function M.getDevices(callback)
	local devices = objManager:GetManagedObjects()
	for path, _ in pairs(devices) do
		local dev = p.Proxy:new {
			bus = p.Bus.SYSTEM,
			name = 'org.bluez',
			interface = 'org.bluez.Device1',
			path = path
		}

--[[
		require 'naughty'.notification {
			title = dev.Name,
			text = path
		}
]]--

		if not path:match 'dev' then goto continue end
		--callback(dev)
		::continue::
	end
end

objManager:connect_signal(function(_, interface)
	--M.setupDevice(interface)
end, 'InterfacesAdded')

return M
