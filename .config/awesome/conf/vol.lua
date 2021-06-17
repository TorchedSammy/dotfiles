local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local gears = require("gears")
local naughty = require 'naughty'
local step = 5

local volume = {}

volume.get_volume_state = function(cb)
  awful.spawn.easy_async("pactl list sinks", function(stdout)
    local mute = stdout:match("Mute:%s+(%a+)")
    local volume = stdout:match("%s%sVolume:[%s%a-:%d/]+%s(%d+)%%")

    if mute == "yes" then
      mute = true
    else
      mute = false
    end

    volume = tonumber(volume)

    cb(volume, mute)
  end)
end

volume.up = function()
    awesome.spawn("pactl set-sink-volume @DEFAULT_SINK@ +"..step.."%")
    -- awesome.emit_signal("evil::volume", next_vol, mute)
end

volume.down = function()
    awesome.spawn("pactl set-sink-volume @DEFAULT_SINK@ -"..step.."%")
    -- awesome.emit_signal("evil::volume", next_vol, mute)
end

volume.mute = function()
    awesome.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")
end

return volume

