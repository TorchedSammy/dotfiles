local lgi = require 'lgi'
local p = require 'dbus_proxy'
local nm = p.Proxy:new {
	bus = p.Bus.SYSTEM,
	name = 'org.freedesktop.NetworkManager',
	interface = 'org.freedesktop.NetworkManager',
	path = '/org/freedesktop/NetworkManager'
}

local devPath = nm:GetDeviceByIpIface 'wlp2s0'
local dev = p.Proxy:new {
	bus = p.Bus.SYSTEM,
	name = 'org.freedesktop.NetworkManager',
	interface = 'org.freedesktop.NetworkManager.Device.Wireless',
	path = devPath
}

local function apPathToProxy(path)
	local ap = p.Proxy:new {
		bus = p.Bus.SYSTEM,
		name = 'org.freedesktop.NetworkManager',
		interface = 'org.freedesktop.NetworkManager.AccessPoint',
		path = path
	}

	return ap
end

local M = {
	enabled = nm.WirelessEnabled,
	activeSSID = nil,
	connectingSSID = nil,
	connectivity = 0,
	state = 0,

	-- "enums"
	CONNECTIVITY_UNKNOWN = 0,
	CONNECTIVITY_NONE = 1,
	CONNECTIVITY_PORTAL = 2,
	CONNECTIVITY_LIMITED = 3,
	CONNECTIVITY_FULL = 4,
}

local function bytesToString(b)
	if not b then return end

	return tostring(lgi.GLib.Bytes(b):get_data())
end

local function emitActiveAP()
	if M.connectivity < M.CONNECTIVITY_NONE then
	end

	awesome.emit_signal('wifi::activeAP', M.activeSSID, M.activeAP)
end

function setConnectingSSID()
	local ap = apPathToProxy(dev.ActiveAccessPoint)
	M.connectingSSID = bytesToString(ap.Ssid)
end

function setActiveSSID()
	local ap = apPathToProxy(dev.ActiveAccessPoint)
	M.activeSSID = bytesToString(ap.Ssid)
	M.activeAP = ap

	if M.connectivity > M.CONNECTIVITY_NONE then
		emitActiveAP()
	end
end
setActiveSSID()

nm:on_properties_changed(function(p, changed)
	if changed.WirelessEnabled ~= nil and changed.WirelessEnabled ~= M.enabled then
		M.enabled = changed.WirelessEnabled
		awesome.emit_signal('wifi::toggle', M.enabled)
	end

	if changed.State ~= nil then
		M.state = math.floor(changed.State)
		if M.state >= 40 then
			setActiveSSID()
			M.connectingSSID = nil
		else
			M.activeSSID = nil
			awesome.emit_signal('wifi::disconnected')
		end
	end

	for k, v in pairs(changed) do
		require'naughty'.notify {
			title = 'NMCli Property changed: ' .. tostring(k),
			text = tostring(v)
		}
	end
end)

dev:on_properties_changed(function(p, changed)
	if changed.ActiveAccessPoint ~= nil then
		setConnectingSSID()
	end
end)

function M.toggle()
	nm:Set('org.freedesktop.NetworkManager', 'WirelessEnabled', lgi.GLib.Variant('b', not M.enabled))
	nm.WirelessEnabled = {
		signature = 'b',
		value = not M.enabled,
	}
	M.activeSSID = nil
end

-- return: table of type AccessPoint
-- AccessPoint has the folling properties:
-- ssid: name
-- security: a string or table possibly idk ill decide
function M.getAccessPoints()
	local apPaths = dev:GetAllAccessPoints()
	local aps = {}

	for k, v in pairs(apPaths) do
		local ap = apPathToProxy(v)
		aps[bytesToString(ap.Ssid) or 'Unknown'] = ap
	end

	for k, v in pairs(aps) do
		require'naughty'.notify {
			title = tostring(k),
			text = tostring(v)
		}
	end

	return aps
end

return M
