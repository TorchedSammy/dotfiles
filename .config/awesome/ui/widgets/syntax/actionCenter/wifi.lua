local awful = require 'awful'
local beautiful = require 'beautiful'
local base = require 'ui.components.syntax.base'
local dpi = beautiful.dpi
local gears = require 'gears'
local helpers = require 'helpers'
local lgi = require 'lgi'
local NM = lgi.NM
local GLib = lgi.GLib
local rubato = require 'modules.rubato'
local settings = require 'conf.settings'
local wibox = require 'wibox'
local w = require 'ui.widgets'

local nmc = NM.Client.new()
local wifiDevice = nmc:get_device_by_iface 'wlo1'

local M = {
	enabled = nmc:wireless_get_enabled(),
	list = wibox.layout.fixed.vertical()
}
M.list:add(w.icon('wifi-ap-locked', {size = beautiful.dpi(28)}))

-- @return boolean state of the setting (on or off)
function M.toggle()
	local conn = wifiDevice.active_connection
	M.enabled = not nmc:wireless_get_enabled()
	if conn then
		wifiDevice:disconnect_async(nil)
	end
	nmc:dbus_set_property(NM.DBUS_PATH, NM.DBUS_INTERFACE, 'WirelessEnabled', GLib.Variant('b', M.enabled), -1, nil, nil)

	return M.enabled
end

function isEmpty(t)
	if t == nil then return true end
	local next = next
	if next(t) then return false else return true end
end

function flagsToSecurity(flags, wpa, rsn)
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

function M.addAP(ap, layout)
	local ssid = ap:get_ssid()
	local secure = flagsToSecurity(ap:get_flags(), ap:get_wpa_flags(), ap:get_rsn_flags()) ~= ''
	require 'naughty'.notify {
		title = 'Access Point Added',
		text = NM.utils_ssid_to_utf8(ssid:get_data())
	}

	local apWidget = wibox.widget {
		layout = wibox.layout.fixed.horziontal,
		w.icon(secure and 'wifi-ap-locked' or 'wifi-ap', {size = beautiful.dpi(28)}),
		{
			widget = wibox.widget.textbox,
			markup = helpers.colorize_text(NM.utils_ssid_to_utf8(ssid:get_data()), beautiful.fg_normal)
		}
	}
	layout:add(apWidget)
end

function M.update(layout)
	wifiDevice:request_scan_async(nil, function(client, result, data)
		for _, ap in ipairs(wifiDevice:get_access_points()) do
			local ssid = ap:get_ssid()
			print(device, ap)

			M.addAP(ap, layout)
		end
	end)
end

function M.display(layout)
	M.update(layout)

	return M.list
end

return M
