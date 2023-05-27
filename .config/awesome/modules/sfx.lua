local awful = require 'awful'
local beautiful = require 'beautiful'
local step = 5
local sounds = {
	notification = 'notify2.wav',
}

local M = {}
function M.play(s)
	awful.spawn.easy_async(string.format('pacat --property=media.role=event %s', beautiful.config_path .. 'sounds/' .. sounds[s]), function() end)
end

function M.notify()
	M.play 'notification'
end

function M.get_volume_state(cb)
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
end

function M.volumeUp()
    awesome.spawn('pactl set-sink-volume @DEFAULT_SINK@ +'..step..'%')
    -- awesome.emit_signal('evil::volume', next_vol, mute)
end

function M.volumeDown()
    awesome.spawn('pactl set-sink-volume @DEFAULT_SINK@ -'..step..'%')
    -- awesome.emit_signal('evil::volume', next_vol, mute)
end

function M.setVolume(vol)
	awesome.spawn('pactl set-sink-volume @DEFAULT_SINK@ '..vol..'%')
	-- awesome.emit_signal('evil::volume', next_vol, mute)
end

function M.muteVolume()
    awesome.spawn('pactl set-sink-mute @DEFAULT_SINK@ toggle')
end

return M
