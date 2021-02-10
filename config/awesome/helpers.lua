local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = {}

helpers.rrect = function(radius)
  return function(c, width, height)
    gears.shape.rounded_rect(c, width, height, radius)
  end
end

helpers.colorize_text = function(text, color)
    return "<span foreground='" .. color .."'>" .. text .. "</span>"
end

return helpers
