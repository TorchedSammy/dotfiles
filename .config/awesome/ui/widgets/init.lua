local awful = require 'awful'
local wibox = require 'wibox'
local gears = require 'gears'
local beautiful = require 'beautiful'
local xresources = require 'beautiful.xresources'
local dpi = xresources.apply_dpi
local sfx = require 'modules.sfx'
local helpers = require 'helpers'
local naughty = require 'naughty'

local function rounded_bar(color)
	return wibox.widget {
		max_value = 100,
		value = 0,
		forced_height = dpi(14),
		forced_width  = dpi(60),
		margins = {
			top = dpi(10),
			bottom = dpi(10),
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
widgets.imgwidget = function(icon, args)
	args = args or {}
	local w = {
		image = type(icon) == 'string' and beautiful.config_path .. '/images/' .. icon or icon,
		widget = wibox.widget.imagebox
	}
	local wArgs = gears.table.join(w, args)

	local ico = wibox.widget(wArgs)

	return ico
end

function widgets.icon(name, opts)
	opts = opts or {}

	local ico = wibox.widget {
		layout = wibox.container.place,
		{
			widget = wibox.container.constraint,
			width = opts.size and opts.size or beautiful.dpi(18),
			{
				widget = wibox.widget.imagebox,
				image = beautiful.config_path .. '/images/icons/' .. name .. '.svg',
				stylesheet = string.format([[
					* {
						fill: %s;
					}
				]], opts.color or beautiful.fg_normal),
				id = 'icon'
			}
		}
	}
	if opts.bgcolor then helpers.displayClickable(ico, {color = opts.bgcolor}) end

	return setmetatable({}, {
			__index = function(_, k)
				return ico[k]
			end,
			__newindex = function(_, k, v)
				if k == 'icon' then
					ico:get_children_by_id'icon'[1].image = gears.color.recolor_image(beautiful.config_path .. '/images/icons/' .. v .. '.svg', beautiful.fg_normal)
					ico:emit_signal 'widget::redraw_needed'
				elseif k == 'color' then
					ico:get_children_by_id'icon'[1].stylesheet = string.format([[
						* {
							fill: %s;
						}
					]], v)
					ico:emit_signal 'widget::redraw_needed'
				end
				ico[k] = v
			end
		})
end

function widgets.button(icon, opts)
	opts = opts or {}

	local focused = false
	local ico = wibox.widget {
		id = 'bg',
		widget = wibox.container.background,
		color = opts.bgcolor,
		shape = opts.shape or (opts.text and helpers.rrect(6) or gears.shape.circle),
		{
			widget = wibox.container.margin,
			margins = beautiful.dpi(2),
			{
				layout = wibox.container.place,
				valign = 'center',
				--halign = 'center',
				--align = 'center',
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.dpi(4),
					{
						widget = wibox.container.constraint,
						width = opts.size and opts.size + 2 or beautiful.dpi(18),
						{
							widget = wibox.widget.imagebox,
							image = beautiful.config_path .. '/images/icons/' .. icon .. '.svg',
							stylesheet = string.format([[
								* {
									fill: %s;
								}
							]], opts.color or beautiful.fg_normal),
							id = 'icon'
						},
					},
					{
						widget = wibox.widget.textbox,
						markup = helpers.colorize_text(opts.text or '', opts.color or beautiful.fg_normal),
						font = beautiful.font:gsub('%d+$', opts.fontSize or 14)
					}
				}
			}
		}
	}
	helpers.displayClickable(ico, opts)

	ico.buttons = {
		awful.button({}, 1, function()
			if opts.onClick then opts.onClick() end
		end),
	}

	local function setupIcon()
		--ico:get_children_by_id'icon'[1].image = gears.color.recolor_image(ico:get_children_by_id'icon'[1].image, focused and beautiful.fg_normal .. 55 or beautiful.fg_normal)
		ico:emit_signal 'widget::redraw_needed'
	end

	ico:connect_signal('mouse::enter', function()
		focused = true
		setupIcon()
	end)
	ico:connect_signal('mouse::leave', function()
		focused = false
		setupIcon()
	end)

	ico.visible = true
	return setmetatable({}, {
		__index = function(_, k)
			return ico[k]
		end,
		__newindex = function(_, k, v)
			if k == 'icon' then
				ico:get_children_by_id'icon'[1].image = gears.color.recolor_image(beautiful.config_path .. '/images/icons/' .. v .. '.svg', beautiful.fg_normal)
				ico:emit_signal 'widget::redraw_needed'
			elseif k == 'color' then
				ico:get_children_by_id'icon'[1].stylesheet = string.format([[
					* {
						fill: %s;
					}
				]], v)
				ico:emit_signal 'widget::redraw_needed'
			end
			ico[k] = v
		end
	})
end

widgets.ram_bar = rounded_bar(beautiful.ram_bar_color)

widgets.ram_icon = wibox.widget {
	markup = '',
	font = 'VictorMono Nerd Font 16',
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

--[[
widgets.volume_bar = rounded_bar(beautiful.xcolor2)
function update_volume_bar(volume, mute)
    widgets.volume_bar.value = volume
    if mute then
        widgets.volume_bar.color = beautiful.xforeground
    else
        widgets.volume_bar.color = beautiful.xcolor2
    end
end

widgets.volume_bar:buttons(gears.table.join(
    awful.button({ }, 4, sfx.volumeUp),
    awful.button({ }, 5, sfx.volumeDown),
    awful.button({ }, 1, function() sfx.muteVolume() sfx.get_volume_state(update_volume_bar) end),
    awful.button({ }, 3, function() awful.spawn 'pavucontrol' end)))

awesome.connect_signal("evil::volume", update_volume_bar)

-- Init widget state
sfx.get_volume_state(update_volume_bar)
]]--

-- Music widget thatll say whats currently playing
widgets.music_icon = wibox.widget {
	markup = '',
	font = 'Font Awesome',
	widget = wibox.widget.textbox
}
widgets.music_name = wibox.widget {
		markup = 'Nothing Playing',
		widget = wibox.widget.textbox,
}

widgets.music = wibox.widget {
	layout = wibox.layout.fixed.horizontal,
	spacing = beautiful.dpi(4),
	widgets.music_icon,
	widgets.music_name
}

widgets.textclock = wibox.widget.textclock()
widgets.textclock.format = '%-I:%M %p'
widgets.time = wibox.widget {
	layout = wibox.layout.fixed.horizontal,
	spacing = 5,
	{
		widget = wibox.widget.textbox,
		text = '',
		font = 'Font Awesome 20'
	},
	widgets.textclock
}

widgets.macos_time = wibox.widget.textclock()
widgets.macos_time.format = '%-I:%M %p'

widgets.date = wibox.widget.textclock()
widgets.date.format = ' %d %b'

widgets.macos_date = wibox.widget.textclock()
widgets.macos_date.format = '%a %b %d'

-- Systray
function widgets.systray(opts)
	local systray_margin = (beautiful.wibar_height - beautiful.systray_icon_size) / 2
	widgets.raw_systray = wibox.widget.systray()
	widgets.raw_systray:set_base_size(beautiful.systray_icon_size)

	local popup
	local btn
	btn = widgets.button('systray', {
		bg = opts.bg,
		onClick = function()
			if awesome.systray() ~= 0 then
				--popup:move_next_to(btn)
				popup.visible = not popup.visible
			end
		end
	})
	--[[
	local oldDraw = btn.draw
	function btn:draw()
	end
	]]--

	local systrayPopup = wibox.widget {
		{
			widgets.raw_systray,
			top = systray_margin,
			bottom = systray_margin,
			widget = wibox.container.margin	
		},
		widget = wibox.container.background,
		shape = helpers.rrect(6)
	}

	popup = awful.popup {
		widget = systrayPopup,
		shape = helpers.rrect(6),
		ontop = true,
		visible = false,
		hide_on_right_click = true,
		preferred_positions = 'top',
		placement = function(w)
			awful.placement.bottom_right(w, {
				margins = {
					bottom = beautiful.dpi(beautiful.wibar_height) + beautiful.useless_gap, right = beautiful.dpi(32)
				},
				parent = awful.screen.focused()
			})
		end
	}
	--popup:move_next_to(btn)
	helpers.hideOnClick(popup)

	return btn
end

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

widgets.volslider = wibox.widget {
	widget = wibox.widget.slider,
	value = 100,
	bar_shape = gears.shape.rounded_rect,
	bar_height = dpi(4),
	bar_color = beautiful.xforeground,
	bar_active_color = beautiful.xforeground,
	handle_color = beautiful.xforeground,
	handle_shape = gears.shape.circle,
	forced_width = 100,
}

sfx.get_volume_state(function(volume)
	widgets.volslider.value = volume
end)

widgets.volslider:connect_signal('property::value', function()
	sfx.setVolume(widgets.volslider.value)
end)

function widgets.switch(opts)
	local size = {
		w = beautiful.dpi(52),
		h = beautiful.dpi(20),
	}

	local progress = wibox.widget {
		widget = wibox.widget.progressbar,
		background_color = beautiful.bg_normal,
		color = opts.color,
		shape = gears.shape.rounded_bar,
		bar_shape = gears.shape.rounded_bar,
		forced_height = size.h,
		forced_width = size.w,
		max_value = 100
	}

	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_width = size.w,
		forced_height = size.h,
		bar_color = '#00000000',
		--handle_width = progress.forced_height,
		handle_color = beautiful.fg_normal,
		handle_border_color = beautiful.bg_normal,
		handle_border_width = 1,
		handle_shape = gears.shape.circle,
		maximum = 100
	}

	local cover = wibox.widget {
		widget = wibox.container.background,
		bg = '#ffae23',
		forced_width = size.w,
		forced_height = size.h,
	}

	local switch = wibox.widget {
		layout = wibox.layout.stack,
		progress,
		slider,
		cover
	}
	switch.buttons = {
		awful.button({}, 1, function()
			progress.value = 100
			slider.value = 100
		end)
	}

	helpers.hoverCursor(switch)

	return switch
end

return widgets

