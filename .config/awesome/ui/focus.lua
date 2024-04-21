local gears = require 'gears'

local canFocus = true
local focusTimerUp = true

local focusTimer
local M = {
	currentWidget = nil,
	currentObj = nil,
	focusObjHandler = function()
		focusTimer:stop()
		focusTimer:start()
	end
}

local function focusDone()
	canFocus = true
	focusTimerUp = true

	print 'THE REAL FOCUS TIMER IS UP'

	if M.currentObj ~= nil then
		M.currentObj:disconnect_signal('button::press', M.focusStop)
		M.currentObj:disconnect_signal('button::release', M.focusStop)
		M.currentObj:disconnect_signal('mouse::enter', M.panelFocusStart)
		M.currentObj:disconnect_signal('mouse::leave', M.panelFocusStart)
	end
end

local focusTimer = gears.timer {
	timeout = 2,
	single_shot = true,
	callback = focusDone
}

function M.panelFocusStart()
	if not focusTimer.started or focusTimer.timeout ~= 10 then
		print 'LONGER FOCUS TIMEOUT'
		focusTimer:stop()
		focusTimer.timeout = 10
		focusTimer:start()
	end
end

function M.focusStart()
	if focusTimer.started and focusTimer.timeout ~= 10 then
		focusTimer:stop()
		focusTimer.timeout = 2
		print 'focus timer starting'
		focusTimer:start()
	end
end

function M.focusStop()
	print('focus timer stopping')
	focusTimer:stop()
	focusTimer.timeout = 2
end

function M.passthrough(new)
	if new.popup then return end

	if M.currentWidget and M.currentWidget ~= new then
		M.currentWidget:off()
	end

	M.currentWidget = new
	--M.lock(new)
end

function M.lock(obj)
	if M.currentObj == obj or focusTimerUp then
		M.currentObj = obj
		M.focusStop()
	
		canFocus = false
		focusTimerUp = false
		M.focusStart()

		obj:connect_signal('button::press', M.focusStop)
		obj:connect_signal('button::release', M.panelFocusStart)
		obj:connect_signal('mouse::enter', M.panelFocusStart)
		obj:connect_signal('mouse::leave', M.focusStart)
	end
end

function M.unlock()
	M.focusStop()
	focusDone()
end

return M
