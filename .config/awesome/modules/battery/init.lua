local upower = require 'lgi'.UPowerGlib

local M = {}

local battery = upower.Client():get_display_device()
local statusNames = {
	[upower.DeviceState.PENDING_DISCHARGE] = "Discharging",
	[upower.DeviceState.PENDING_CHARGE]    = "Charging",
	[upower.DeviceState.FULLY_CHARGED]     = "Full",
	[upower.DeviceState.EMPTY]             = "N/A",
	[upower.DeviceState.DISCHARGING]       = "Discharging",
	[upower.DeviceState.CHARGING]          = "Charging",
	[upower.DeviceState.UNKNOWN]           = "N/A"
}

local function formatTime(t)
	local hours = math.floor(t/3600)
	local mins = math.floor(t/60 - (hours*60))
	local secs =  math.floor(t - hours*3600 - mins *60)

	local entries = {}
	if hours > 0 then table.insert(entries, string.format('%d hours', hours)) end
	if mins > 0 then table.insert(entries, string.format('%d minutes', mins)) end
	--if secs > 0 then table.insert(entries, string.format('%d seconds', secs)) end

	return table.concat(entries, ', ')
end

local oldStates = {}
local function updateStats()
	local state = statusNames[battery.state]
	local percentage = math.floor(battery.percentage)
	local time
	if state == 'Charging' then
		time = formatTime(battery.time_to_full) .. ' until full'
	else
		time = formatTime(battery.time_to_empty) .. ' until empty'
	end

	if state ~= oldStates.status then
		awesome.emit_signal('battery::status', state)
		awesome.emit_signal('battery::percentage', percentage)
		awesome.emit_signal('battery::time', time)
	end
	if percentage ~= oldStates.percentage then
		awesome.emit_signal('battery::percentage', percentage)
	end
	if time ~= oldStates.time then
		awesome.emit_signal('battery::time', time)
	end

	oldStates.percentage = percentage
	oldStates.status = state
end

updateStats()
battery.on_notify = updateStats

function M.status()
	return statusNames[battery.state]
end

function M.percentage()
	return battery.percentage
end

function M.time()
	local state = M.status()

	if state == 'Charging' then
		return formatTime(battery.time_to_full) .. ' until full'
	else
		return formatTime(battery.time_to_empty) .. ' until empty'
	end
end

local manager = require 'modules.battery.managers.powerprofilesdaemon'
function M.setProfile(profile)
	manager[profile .. 'Profile']()
end

function M.profile()
	return manager.profile()
end

return M
