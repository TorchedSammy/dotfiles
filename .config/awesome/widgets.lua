local awful = require 'awful'
local wibox = require 'wibox'
local gears = require 'gears'
local beautiful = require 'beautiful'
local xresources = require 'beautiful.xresources'
local dpi = xresources.apply_dpi

local function rounded_bar(color)
	return wibox.widget {
		max_value = 100,
		value = 0,
		forced_height = dpi(14),
		forced_width  = dpi(60),
		margins = {
			top = dpi(8),
			bottom = dpi(8),
		},
		shape = gears.shape.rounded_bar,
		border_width = 1,
		color = color,
		background_color = beautiful.bg_sec,
		border_color = color,
		widget = wibox.widget.progressbar
	}
end

local widgets = {}

widgets.ram_bar = rounded_bar(beautiful.ram_bar_color)

awful.widget.watch('cat /proc/meminfo', 5, function(widget, stdout)
  local total = stdout:match 'MemTotal:%s+(%d+)'
  local free = stdout:match 'MemFree:%s+(%d+)'
  local buffers = stdout:match 'Buffers:%s+(%d+)'
  local cached = stdout:match 'Cached:%s+(%d+)'
  local srec = stdout:match 'SReclaimable:%s+(%d+)'
  local used_kb = total - free - buffers - cached - srec
  widget.value = used_kb / total * 100
end, widgets.ram_bar)

-- Music widget thatll say whats currently playing
widgets.music_icon = wibox.widget {
	markup = '',
	font = 'Font Awesome 5 Free Regular',
	widget = wibox.widget.textbox
}
widgets.music = wibox.widget {
	markup = 'Nothing Playing',
	widget = wibox.widget.textbox
}

widgets.time = wibox.widget.textclock()
widgets.time.format = ' %I:%M %p'

widgets.date = wibox.widget.textclock()
widgets.date.format = '%d/%m/%y'

-- Systray
local systray_margin = (beautiful.wibar_height - beautiful.systray_icon_size) / 2
widgets.raw_systray = wibox.widget.systray()
widgets.raw_systray:set_base_size(beautiful.systray_icon_size)

widgets.systray = wibox.widget {
	widgets.raw_systray,
	top = systray_margin,
	bottom = systray_margin,
	--right = 5, left = 5,
	widget = wibox.container.margin
}

local layoutbox = awful.widget.layoutbox(s)
layoutbox:buttons(gears.table.join(
	awful.button({}, 1, function()
		awful.layout.inc(1)
	end),
	awful.button({}, 3, function()
		awful.layout.inc(-1)
	end),
))
	
widgets.layout = {
	layoutbox,
	top = 7, bottom = 7,
	widget = wibox.container.margin
}

return widgets

