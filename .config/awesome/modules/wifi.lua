local awful = require 'awful'
local beautiful = require 'beautiful'
local base = require 'ui.components.syntax.base'
local dpi = beautiful.dpi
local gears = require 'gears'
local helpers = require 'helpers'
local lgi = require 'lgi'
local NM = lgi.NM
local GLib = lgi.GLib
local rubato = require 'libs.rubato'
local settings = require 'conf.settings'
local wibox = require 'wibox'
local w = require 'ui.widgets'
local naughty = require 'naughty'

local nmc = NM.Client.new()
local wifiDevice = nmc:get_device_by_iface 'wlo1'

local M = {
	enabled = nmc:wireless_get_enabled() and wifiDevice ~= nil,
}

-- @return boolean state of the setting (on or off)
function M.toggle()
	if not wifiDevice then return false end

	local conn = wifiDevice.active_connection
	if conn then
		wifiDevice:disconnect_async(nil)
	end

	M.enabled = not nmc:wireless_get_enabled()
	nmc:dbus_set_property(NM.DBUS_PATH, NM.DBUS_INTERFACE, 'WirelessEnabled', GLib.Variant('b', M.enabled), -1, nil, nil)

	if M.enabled then
		wifiDevice:request_scan_async(nil)
	end

	return M.enabled
end

function isEmpty(t)
	if t == nil then return true end
	local next = next
	if next(t) then return false else return true end
end

function M.getAPSecurity(ap)
	local flags = ap:get_flags()
	local wpa = ap:get_wpa_flags()
	local rsn = ap:get_rsn_flags()

	local str = ''
	if flags['PRIVACY'] and isEmpty(wpa) and isEmpty(rsn) then
		str = str .. ' WEP'
	end
	if not isEmpty(wpa) then
		str = str .. ' WPA1'
	end
	if not isEmpty(rsn) then
		str = str .. ' WPA2'
	end
	if wpa['KEY_MGMT_802_1X'] or rsn['KEY_MGMT_802_1X'] then
		str = str .. ' 802.1X'
	end

	return (str:gsub('^%s', ''))
end

function M.getAPs(callback)
	wifiDevice:request_scan_async(nil, function(client, result, data)
		for _, ap in ipairs(wifiDevice:get_access_points()) do
			callback(ap)
		end
	end)
end

function M.getSSID(ap)
	local ssid = ap:get_ssid()
	return NM.utils_ssid_to_utf8(ssid:get_data())
end

function M.connect(ap, pass)
	local ssid = M.getSSID(ap)
	local profile = NM.SimpleConnection.new()

	local conn = NM.SettingConnection.new()
	local swlan = NM.SettingWireless.new()
	profile:add_setting(swlan)
	profile:add_setting(conn)

	conn['id'] = ssid
	conn['type'] = '802-11-wireless'
	swlan['ssid'] = GLib.Bytes(ssid)

	if M.getAPSecurity(ap) ~= '' then
		local swsec = NM.SettingWirelessSecurity.new()
		profile:add_setting(swsec)

		-- TODO: wep and open wifi
		swsec['key-mgmt'] = 'wpa-psk'
		swsec['auth-alg'] = 'open'
		swsec['psk'] = pass
	end

	nmc:add_and_activate_connection_async(profile, nmc:get_device_by_iface 'wifi', profile:get_path(), nil, function(client, result, data)
		local con, err, code = nmc:add_and_activate_connection_finish(result)
		if not con then
			naughty.notify {
				title = 'Error while attempting to add connection...',
				text = tostring(err)
			}
			print(code)
			print(err)
		end
	end, nil)
end

function M.isActiveAP(ap)
	local ssid = M.getSSID(ap)

	return M.activeAPSSID == ssid
end

do
	if wifiDevice then
		local activeAP = wifiDevice:get_active_access_point()
		if activeAP then
			M.activeAPSSID = M.getSSID(activeAP)
		end
	end
end

return M
