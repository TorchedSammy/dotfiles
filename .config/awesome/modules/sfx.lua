local awful = require 'awful'
local beautiful = require 'beautiful'
local step = 5
local sounds = {
	notification = 'notify6.wav',
	deviceAdded = 'device-added2.wav',
	deviceRemoved = 'device-removed2.wav',
}

local M = {
	volume = 0.60
}

local function spawn(cmd, cb)
	awful.spawn.easy_async(cmd, cb or function() end)
end

function M.play(s)
	local cmd = string.format('pw-play --volume %f --properties=media.role=event %s', M.volume, beautiful.config_path .. 'sounds/' .. (sounds[s] or s .. '.wav'))
	awful.spawn.easy_async(cmd, function() end)
end

function M.notify()
	M.play 'notification'
end

function M.state(cb)
	spawn('pamixer --get-mute && pamixer --get-volume', function(stdout)
		local mute = stdout:match '([truefalse]+)' == 'true'

		cb(volume, mute)
	end)
	--[[
	awful.spawn.easy_async('pactl list sinks', function(stdout)
		local mute = stdout:match('Mute:%s+(%a+)')
		local volpercent = stdout:match('%s%sVolume:[%s%a-:%d/]+%s(%d+)%%')

		if mute == 'yes' then
			mute = true
		else
			mute = false
		end

		volpercent = tonumber(volpercent)

		cb(volpercent, mute)
	end)
	]]--
end

function M.volumeUp()
	spawn('pactl set-sink-volume @DEFAULT_SINK@ +'..step..'%')
	-- awesome.emit_signal('evil::volume', next_vol, mute)
end

function M.volumeDown()
	spawn('pactl set-sink-volume @DEFAULT_SINK@ -'..step..'%')
	-- awesome.emit_signal('evil::volume', next_vol, mute)
end

function M.setVolume(vol)
	spawn('pactl set-sink-volume @DEFAULT_SINK@ '..vol..'%')
	-- awesome.emit_signal('evil::volume', next_vol, mute)
end

function M.muteVolume()
	spawn('pamixer --toggle-mute')
end

return M
