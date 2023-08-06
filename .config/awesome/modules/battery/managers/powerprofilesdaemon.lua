local lgi = require 'lgi'
local p = require 'dbus_proxy'
local proxy = p.Proxy:new {
	bus = p.Bus.SYSTEM,
	name = 'net.hadess.PowerProfiles',
	interface = 'net.hadess.PowerProfiles',
	path = '/net/hadess/PowerProfiles'
}
local M = {}

local function setProfile(profile)
	proxy:Set('net.hadess.PowerProfiles', 'ActiveProfile', lgi.GLib.Variant('s', profile))
	proxy.ActiveProfile = {
		signature = 's',
		value = profile,
	}
end

function M.performanceProfile()
	setProfile 'performance'
end

function M.powerSaveProfile()
	setProfile 'power-saver'
end

function M.balancedProfile()
	setProfile 'balanced'
end

function M.profile()
	local profile = proxy.ActiveProfile

	if profile == 'power-saver' then return 'powerSave' end
	if profile == 'balanced' then return 'balanced' end
	if profile == 'performance' then return 'performance' end
end
return M
