local wibox = require 'wibox'
local awful = require 'awful'
local gears = require 'gears'
local beautiful = require 'beautiful'
local xresources = require 'beautiful.xresources'
local dpi = xresources.apply_dpi
local sfx = require 'modules.sfx'
local helpers = require 'helpers'
local naughty = require 'naughty'
local cairo = require 'lgi'.cairo
local battery = require 'modules.battery'
local rubato = require 'libs.rubato'
local wifi = require 'modules.wifi'

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
				vertical_fit_policy = opts.vertical_fit_policy,
				horizontal_fit_policy = opts.horizontal_fit_policy,
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
					ico:get_children_by_id'icon'[1].image = gears.color.recolor_image(beautiful.config_path .. '/images/icons/' .. v .. '.svg', opts.color or beautiful.fg_normal)
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
	opts = opts or (type(icon) == 'table' and icon or {})

	local focused = false
	local ico = wibox.widget {
		layout = wibox.container.constraint,
		height = opts.height,
		strategy = 'exact',
		{
			id = 'bg',
			widget = wibox.container.background,
			bg = opts.bgcolor or opts.bg,
			shape = opts.shape or (opts.text and helpers.rrect(6) or gears.shape.circle),
			{
				widget = wibox.container.margin,
				margins = opts.margin or beautiful.dpi(2),
				{
					layout = wibox.container.place,
					halign = 'center',
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.dpi(4),
						(icon ~= '' and icon ~= nil) and {
							layout = wibox.container.place,
							valign = 'center',
							halign = 'center',
							align = 'center',
							{
								widget = wibox.container.constraint,
								width = opts.size and opts.size + 2 or beautiful.dpi(18),
								{
									widget = wibox.widget.imagebox,
									image = beautiful.config_path .. '/images/icons/' .. icon.. '.svg',
									stylesheet = string.format([[
										* {
											fill: %s;
										}
									]], opts.color or beautiful.fg_normal),
									id = 'icon'
								},
							},
						} or nil,
						{
							widget = wibox.widget.textbox,
							markup = helpers.colorize_text(opts.text or '', opts.color or beautiful.fg_normal),
							font = opts.font or beautiful.font:gsub('%d+$', opts.fontSize or 14),
							id = 'textbox',
							valign = 'center'
						}
					}
				}
			}
		}
	}
	helpers.displayClickable(ico, opts)

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
	local realWid
	realWid = setmetatable({}, {
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
			elseif k == 'text' then
				ico:get_children_by_id'textbox'[1].markup = helpers.colorize_text(v, opts.color or beautiful.fg_normal)
			elseif k == 'onClick' and type(v) == 'function' then
				realWid.buttons = {
					awful.button({}, 1, function()
						v(realWid)
					end),
				}
			end
			ico[k] = v
		end
	})
	realWid.buttons = {
		awful.button({}, 1, function()
			if opts.onClick then opts.onClick(realWid) end
		end),
	}

	return realWid
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

widgets.music_name = wibox.widget {
	markup = 'Nothing Playing',
	widget = wibox.widget.textbox,
}

widgets.music = wibox.widget {
	layout = wibox.layout.fixed.horizontal,
	spacing = beautiful.dpi(4),
	widgets.icon 'music',
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
function find_widget_in_wibox(wb, widget)
  local function find_widget_in_hierarchy(h, widget)
	if h:get_widget() == widget then
	  return h
	end
	local result
	for _, ch in ipairs(h:get_children()) do
	  result = result or find_widget_in_hierarchy(ch, widget)
	end
	return result
  end
  local h = wb._drawable._widget_hierarchy
  return h and find_widget_in_hierarchy(h, widget)
end

function widgets.systray(opts)
	local systray_margin = (beautiful.wibar_height - beautiful.systray_icon_size) / 3
	widgets.raw_systray = wibox.widget.systray()
	widgets.raw_systray:set_base_size(beautiful.systray_icon_size)

	local popup
	local btn
	local wid

	local function adjustSystray()
		local w = find_widget_in_wibox(opts.bar, wid)
		if not w then return 0, 0 end

		local bx, by, width, height = w:get_matrix_to_device():transform_rectangle(0, 0, w:get_size())

		local x = opts.vertical
			and bx + width + beautiful.useless_gap
			or bx + (width / 2) - (((beautiful.systray_icon_size * awesome.systray()) + (beautiful.systray_icon_spacing * (awesome.systray() - 1))) / 2)
		local y = opts.vertical
			and by + height + beautiful.useless_gap
			or screen.primary.geometry.height - height - beautiful.wibar_height - (beautiful.useless_gap * 2) - (opts.margin and opts.margin or 0)

		return x, y
	end

	local function setPopupPos(px, py)
		popup.x = px
		popup.y = py
	end

	widgets.raw_systray:connect_signal('widget::layout_changed', function()
		--setPopupPos(adjustSystray())
	end)

	btn = widgets.button('expand-more', {
		bg = opts.bg,
		onClick = function()
			if awesome.systray() ~= 0 then
				--setPopupPos(adjustSystray())
				
				popup:toggle()
			end
		end
	})
	--[[
	local oldDraw = btn.draw
	function btn:draw()
	end
	]]--

	local systrayPopup = wibox.widget {
		widgets.raw_systray,
		margins = systray_margin,
		widget = wibox.container.margin
	}

	popup = awful.popup {
		widget = systrayPopup,
		shape = helpers.rrect(6),
		ontop = true,
		visible = false,
		bg = beautiful.bg_popup
		--[[
		placement = function(w)
			awful.placement.bottom_right(w, {
				margins = {
					bottom = beautiful.dpi(beautiful.wibar_height) + beautiful.useless_gap, right = beautiful.dpi(32)
				},
				parent = awful.screen.focused()
			})
		end
		]]--
	}
	--popup:move_next_to(btn)

	if opts.vertical then
		wid = wibox.widget {
			widget = wibox.container.rotate,
			direction = 'west',
			btn
		}
	else
		wid = btn
	end

	helpers.slidePlacement(popup, {
		placement = 'bottom_right',
		toggler = function(state)
			btn.icon = state and 'expand-less' or 'expand-more'
		end,
		hoffset = systray_margin * 3,
		coords = function()
			local x = adjustSystray()

			return {x = x}
		end
	})

	return wid, popup
end

function widgets.layout(s, size)
	local layoutbox = awful.widget.layoutbox(s)
	layoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end)
	))

	return {
		widget = wibox.container.constraint,
		width = size or beautiful.dpi(18),
		{
			widget = wibox.container.place,
			align = 'center',
			layoutbox
		}
	}
end

--[[
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
]]--

function widgets.switch(opts)
	local size = {
		w = beautiful.dpi(36),
		h = beautiful.dpi(36),
	}

	-- ### Remove mouse interaction from slider
	local base = require 'wibox.widget.base'
	local gtable = require 'gears.table'
	setmetatable(wibox.widget.slider, {
		__call = function()
			local ret = base.make_widget(nil, nil, {
				enable_properties = true,
			})

			gtable.crush(ret._private, args or {})

			gtable.crush(ret, wibox.widget.slider, true)

			--ret:connect_signal("button::press", mouse_press)

			return ret
		end
	})
	-- ###

	local switch = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = size.h,
		forced_width = size.w,
		bar_margins = {
			top = size.h / 3,
			bottom = size.h / 3,
			left = beautiful.dpi(4),
			right = beautiful.dpi(4),
		},
		bar_color = beautiful.xcolor12,
		bar_active_color = beautiful.accent,
		bar_shape = gears.shape.rounded_bar,
		handle_color = beautiful.xcolor7,
		handle_shape = gears.shape.circle,
		handle_border_color = beautiful.accent,
		handle_border_width = 0,
		value = opts.on and 100 or 0,
		on = opts.on,
		handler = opts.handler
	}

	local wid = wibox.widget {
		widget = wibox.container.constraint,
		height = size.h,
		width = size.w,
		switch
	}

	setmetatable(wibox.widget.slider, wibox.widget.slider.mt)

	local animator = rubato.timed {
		duration = 1,
		rate = 60,
		outro = 0.7,
		easing = {
			F = (20*math.sqrt(3)*math.pi-30*math.log(2)-6147) /
				(10*(2*math.sqrt(3)*math.pi-6147*math.log(2))),
			easing = function(t) return
		(4096*math.pi*(2^(10*t-10))*math.cos(20/3*math.pi*t-43/6*math.pi)
		+6144*(2^(10*t-10))*math.log(2)*math.sin(20/3*math.pi*t-43/6*math.pi)
		+2*math.sqrt(3)*math.pi-3*math.log(2)) /
		(2*math.pi*math.sqrt(3)-6147*math.log(2))
			end
		},
		subscribed = function(p)
			switch.value = p
		end,
		pos = switch.value,
	}
	function switch:setState(on, instant)
		if instant then
			switch.value = on and 100 or 0
			animator.target = on and 100 or 0
		else
			animator.target = on and 100 or 0
		end

		switch.on = on
	end

	helpers.hoverCursor(switch)
	wid.buttons = {
		awful.button({}, 1, function()
			if switch.value > 50 then
				switch:setState(false)
			else
				switch:setState(true)
			end
			if switch.handler then switch.handler(switch.on) end
		end)
	}

	return wid
end

function widgets.coloredText(text, opts)
	color = type(opts) == 'table' and opts.color or opts
	local wid = wibox.widget {
		widget = wibox.widget.textbox,
		markup = helpers.colorize_text(text, color),
	}
	wid.color = color
	wid.text = text

	function wid.set(key, value)
		wid[key] = value
		wid:set_markup_silently(helpers.colorize_text(wid.text, wid.color))
	end

	return wid
end

function widgets.battery(opts)
	local background = widgets.icon('battery', {size = opts.size, color = beautiful.xcolor12})
	local indicator = wibox.widget {
		widget = wibox.widget.imagebox,
	}

	local wid = wibox.widget {
		layout = wibox.container.constraint,
		strategy = 'exact',
		width = opts.size,
		{
			layout = wibox.container.place,
			{
				layout = wibox.layout.stack,
				background,
				indicator
			}
		}
	}

	local tt = awful.tooltip {
		objects = {wid},
		preferred_alignments = {'middle'},
		mode = 'outside',
	}

	local function handleBattery()
		local state = battery.status()
		local batIcon = 'battery'
		local color = beautiful.fg_normal

		local time = battery.time()
		if time ~= '' then time = '\n' .. time end
		local text = string.format('%d%% on battery%s', battery.percentage(), time)

		if state == 'Charging' then
			--batIcon = 'battery-charging'
			color = beautiful.xcolor2
		end

		if state == 'Full' then
			text = 'Full'
		end

		tt.text = text
		local batteryImg = gears.color.recolor_image(string.format('%s/images/icons/%s.svg', beautiful.config_path, batIcon), color)
		local img = cairo.ImageSurface.create(cairo.Format.ARGB32, batteryImg:get_width(), batteryImg:get_height())
		local cr = cairo.Context(img)
		cr:set_source_surface(batteryImg, 0, batteryImg:get_height() - (batteryImg:get_height() * (battery.percentage() / 100)))
		cr:paint()

		indicator.image = img
	end
	handleBattery()
	awesome.connect_signal('battery::percentage', handleBattery)

	return wid
end

function widgets.volume(opts)
	local icon = widgets.icon('volume', {size = opts.size})
	local tt = awful.tooltip {
		objects = {icon},
		preferred_alignments = {'middle'},
		mode = 'outside',
	}

	local function setState(volume, muted, init)
		tt.text = string.format('%d%% volume%s', volume, muted and ' (muted)' or '')
		icon.icon = muted and 'volume-muted' or 'volume'
	end


	awesome.connect_signal('syntax::volume', setState)

	return icon
end

function widgets.wifi(opts)
	local stateIcon = wifi.enabled and (wifi.activeSSID and 'wifi' or 'wifi-noap') or 'wifi-off'
	local icon = widgets.icon(stateIcon, {size = opts.size})
	local tt = awful.tooltip {
		objects = {icon},
		preferred_alignments = {'middle'},
		mode = 'outside',
	}

	local function setState(volume, muted, init)
		tt.text = string.format('%d%% volume%s', volume, muted and ' (muted)' or '')
		icon.icon = muted and 'volume-muted' or 'volume'
	end

	awesome.connect_signal('wifi::toggle', function(on)
		icon.icon = on and 'wifi-noap' or 'wifi-off'
	end)

	awesome.connect_signal('wifi::disconnected', function()
		if wifi.enabled then icon.icon = 'wifi-noap' else icon.icon = 'wifi-off' end
	end)

	awesome.connect_signal('wifi::activeAP', function(ssid, ap)
		icon.icon = 'wifi'
	end)

	return icon
end

return widgets
