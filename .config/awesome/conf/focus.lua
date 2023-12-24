local awful = require 'awful'
local gears = require 'gears'

local canFocus = true

local focustimer = gears.timer {
	timeout = 3,
	single_shot = true,
	callback = function()
		canFocus = true
		timerExpired = true
	end
}

local function startFocus()
	focustimer:stop()
	canFocus = false
	timerExpired = false
	focustimer:start()
end

--[[
client.disconnect_signal('request::activate', awful.permissions.activate)
client.connect_signal('button::press', startFocus)

client.connect_signal('request::activate', function(c, context, hints)
	if (context == 'rules') then
		if timerExpired and canFocus then
			awful.permissions.activate(c, context, hints)
		end
		startFocus()
		--awful.permissions.urgent(c, true)
	else
		awful.permissions.activate(c, context, hints)
	end
end)
]]--

local M = {}

function M.shouldUnfocus()
	return true
	--return not timerExpired and canFocus
end

function M.focused()
	startFocus()
end

return M
