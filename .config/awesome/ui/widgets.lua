local awful = require 'awful'
local wibox = require 'wibox'
local gears = require 'gears'
local beautiful = require 'beautiful'
local volume = require 'conf.vol'
local xresources = require 'beautiful.xresources'
local dpi = xresources.apply_dpi
local naughty = require 'naughty'

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

widgets.ram_icon = wibox.widget {
	markup = '',
	font = 'JetBrains Mono Regular Nerd Font Complete Mono 16',
	widget = wibox.widget.textbox
}

widgets.ram_percent = wibox.widget {
	markup = '0%',
	widget = wibox.widget.textbox
}

widgets.ram = {
	layout = wibox.layout.fixed.horizontal,
	spacing = beautiful.dpi(4),
	widgets.ram_icon,
	widgets.ram_percent
}

awful.widget.watch('cat /proc/meminfo', 5, function(widget, stdout)
  local total = stdout:match 'MemTotal:%s+(%d+)'
  local free = stdout:match 'MemFree:%s+(%d+)'
  local buffers = stdout:match 'Buffers:%s+(%d+)'
  local cached = stdout:match 'Cached:%s+(%d+)'
  local srec = stdout:match 'SReclaimable:%s+(%d+)'
  local used_kb = total - free - buffers - cached - srec
  local usepercent = used_kb / total * 100

  -- Set bar percent
  widget.value = usepercent
  -- Set text widget percent
  widgets.ram_percent:set_markup_silently(math.floor(usepercent) .. '%')
end, widgets.ram_bar)

widgets.volume_bar = rounded_bar(beautiful.xcolor1)
function update_volume_bar(vol, mute)
    widgets.volume_bar.value = vol
    if mute then
        widgets.volume_bar.color = beautiful.xforeground
    else
        widgets.volume_bar.color = beautiful.xcolor1
    end
end

widgets.volume_bar:buttons(gears.table.join(
    awful.button({ }, 4, volume.up),
    awful.button({ }, 5, volume.down),
    awful.button({ }, 1, function() volume.mute() volume.get_volume_state(update_volume_bar) end),
    awful.button({ }, 3, function() awful.spawn 'pavucontrol' end)))

awesome.connect_signal("evil::volume", update_volume_bar)

-- Init widget state
volume.get_volume_state(update_volume_bar)

-- Music widget thatll say whats currently playing
widgets.music_icon = wibox.widget {
	markup = '',
	font = 'Font Awesome',
	widget = wibox.widget.textbox
}
widgets.music = wibox.widget {
	layout = wibox.layout.fixed.horizontal,
	spacing = beautiful.dpi(4),
	widgets.music_icon,
	{
		markup = 'Nothing Playing',
		widget = wibox.widget.textbox,
	}
}

widgets.time = wibox.widget.textclock()
widgets.time.format = ' %I:%M %p'

widgets.date = wibox.widget.textclock()
widgets.date.format = ' %d %b'

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
	end)
))
	
widgets.layout = {
	layoutbox,
	top = 7, bottom = 7,
	widget = wibox.container.margin
}

widgets.clientclass = wibox.widget {
		markup = 'AwesomeWM',
		widget = wibox.widget.textbox
}
client.connect_signal("focus", function ()
	local fc = client.focus
	widgets.clientclass:set_markup_silently(fc.class)
end)
awful.tag.attached_connect_signal(client.screen, 'property::selected', function()
	local fc = client.focus
	if not fc then widgets.clientclass:set_markup_silently 'AwesomeWM' end
end)


return widgets

