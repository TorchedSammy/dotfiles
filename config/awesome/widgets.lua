local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local beautiful = require('beautiful')
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local widgets = {}
local function rounded_bar(color)
    return wibox.widget {
        max_value     = 100,
        value         = 0,
        forced_height = dpi(10),
        forced_width  = dpi(60),
        margins       = {
          top = dpi(10),
          bottom = dpi(10),
        },
        shape         = gears.shape.rounded_bar,
        border_width  = 1,
        color         = color,
        background_color = beautiful.bg_normal,
        border_color  = beautiful.border_normal,
        widget        = wibox.widget.progressbar,
    }
end

widgets.ram_bar = rounded_bar(beautiful.ram_bar_color)

awful.widget.watch("cat /proc/meminfo", 5, function(widget, stdout)
  local total = stdout:match("MemTotal:%s+(%d+)")
  local free = stdout:match("MemFree:%s+(%d+)")
  local buffers = stdout:match("Buffers:%s+(%d+)")
  local cached = stdout:match("Cached:%s+(%d+)")
  local srec = stdout:match("SReclaimable:%s+(%d+)")
  local used_kb = total - free - buffers - cached - srec
  widget.value = used_kb / total * 100
end, widgets.ram_bar)

-- Music widget thatll say whats currently playing
widgets.music = wibox.widget {
	markup = ' Nothing Playing',
	font = 'Typicons 11',
	widget = wibox.widget.textbox
}

widgets.time = wibox.widget.textclock()
widgets.time.format = "  %I:%M %p"

return widgets
