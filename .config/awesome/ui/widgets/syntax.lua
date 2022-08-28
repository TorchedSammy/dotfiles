local awful = require 'awful'
local base = require 'ui.components.syntax.base'
local beautiful = require 'beautiful'
local bling = require 'modules.bling'
local dpi = beautiful.dpi
local gears = require 'gears'
local helpers = require 'helpers'
local vol = require 'conf.vol'
local wibox = require 'wibox'
local w = require 'ui.widgets'
local naughty = require 'naughty'

local bgcolor = beautiful.bg_sec
local playerctl = bling.signal.playerctl.lib()
local function button(color_focus, txt, font)
	local focused = false
	local ico = wibox.widget {
		markup = helpers.colorize_text(txt, color_focus),
		font = font or 'VictorMono NF 16',
		widget = wibox.widget.textbox,
		icon = txt,
		align = 'center'
	}

	local function setupIcon()
		ico.markup = helpers.colorize_text(ico.icon, focused and color_focus .. 55 or color_focus)
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
			ico[k] = v
			if k == 'icon' then
				setupIcon()
			elseif k == 'color' then
				color_focus = v
				setupIcon()
			end
		end
	})
end

local widgets = {}

do
	local albumArt = wibox.widget {
		widget = wibox.widget.imagebox,
		resize = true
	}

	local musicArtist = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}

	local musicTitle = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}

	local musicAlbum = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}
	local positionText = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}

	local musicDisplay = wibox {
		width = dpi(480),
		height = dpi(180),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}

	local progressShape = base.shape
	local progress = wibox.widget {
		widget = wibox.widget.progressbar,
		border_color = beautiful.fg_sec,
		border_width = 1,
		forced_height = 18,
		paddings = 2,
		background_color = bgcolor,
		shape = progressShape,
		bar_shape = progressShape
	}
	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = progress.forced_height,
		bar_color = '#00000000'
	}
	slider:connect_signal('property::value', function()
		progress.value = slider.value
		playerctl:set_position(slider.value)
	end)


	local function scroll(widget)
		return wibox.widget {
			layout = wibox.container.scroll.horizontal,
			step_function = wibox.container.scroll.step_functions.nonlinear_back_and_forth,
			max_size = 50,
			speed = 80,
			widget
		}
	end

	local wrappedMusicArtist = scroll(musicArtist)
	local wrappedMusicTitle = scroll(musicTitle)
	local wrappedMusicAlbum = scroll(musicAlbum)

	local shuffle = button(beautiful.fg_normal, '列')
	shuffle:connect_signal('button::press', function()
		playerctl:cycle_shuffle()
	end)

	local position = 0
	local prev = button(beautiful.fg_normal, '玲')
	prev:connect_signal('button::press', function()
		if position >= 5 then
			playerctl:set_position(0)
			return
		end
		playerctl:previous()
	end)

	local playPauseIcons = {'契', ''}
	local playPause = button(beautiful.fg_normal, playPauseIcons[2])
	playPause:connect_signal('button::press', function()
		playerctl:play_pause()
	end)

	local next = button(beautiful.fg_normal, '怜')
	next:connect_signal('button::press', function()
		playerctl:next()
	end)

	playerctl:connect_signal('metadata', function (_, title, artist, art, album)
		musicArtist:set_markup_silently(artist)
		wrappedMusicArtist:emit_signal 'widget::redraw_needed'

		musicTitle:set_markup_silently(title)
		wrappedMusicTitle:emit_signal 'widget::redraw_needed'

		musicAlbum:set_markup_silently(helpers.colorize_text(album, beautiful.fg_sec))
		wrappedMusicAlbum:emit_signal 'widget::redraw_needed'

		albumArt.image = gears.surface.load_uncached_silently(art, beautiful.config_path .. '/images/albumPlaceholder.png')
		positionText:set_markup_silently(helpers.colorize_text('0:00', beautiful.fg_sec))
	end)
	playerctl:connect_signal('position', function (_, pos, length)
		progress.color = string.format('linear:0,0:%s,0:0,%s:%s,%s', math.floor(length), base.gradientColors[1], math.floor(length), base.gradientColors[2])
		progress.max_value = length
		slider.maximum = length
		progress.value = pos
		position = pos

		local mins = math.floor(pos / 60)
		local secs = pos % 60
		local time = string.format('%01d:%02d', mins, secs)
		positionText:set_markup_silently(helpers.colorize_text(time, beautiful.fg_sec))
	end)
	playerctl:connect_signal('playback_status', function(_, playing)
		if not playing then
			playPause.icon = playPauseIcons[1]
		else
			playPause.icon = playPauseIcons[2]
		end
	end)
	playerctl:connect_signal('shuffle', function(_, shuff)
		if shuff then
			shuffle.color = beautiful.xcolor2
		else
			shuffle.color = beautiful.fg_normal
		end
	end)

	local info = wibox.widget {
		layout = wibox.layout.ratio.vertical,
		{
			layout = wibox.layout.fixed.vertical,
			spacing = 6,
			wrappedMusicArtist,
			wrappedMusicTitle,
			wrappedMusicAlbum,
		},
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				prev,
				playPause,
				next
			},
			{
				layout = wibox.container.place
			},
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				--shuffle,
				positionText
			}
		},
		{
			layout = wibox.layout.stack,
			progress,
			{
				layout = wibox.container.place,
				halign = 'center',
				valign = 'center',
				{
					widget = wibox.container.margin,
					top = 2, bottom = 2, left = 2, right = 2,
					slider
				}
			}
		}
	}
	info:ajust_ratio(2, 0.45, 0.15, 0.4)
	info:ajust_ratio(3, 0.85, 0.15, 0)

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		base.sideDecor {
			h = 180,
			bg = bgcolor
		},
		{
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, true, false, false, base.rad) end,
			bg = bgcolor,
			widget = wibox.container.background,
			forced_width = musicDisplay.width - (base.width * 2),
			forced_height = musicDisplay.height,
			{
				widget = wibox.container.margin,
				top = 20, left = 20 - (base.widths.empty + base.widths.round), right = 20, bottom = 20,
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = 18,
					{
						widget = wibox.container.constraint,
						width = 140,
						albumArt
					},
					info
				}
			}
		}
	}
	musicDisplay:setup {
		layout = wibox.container.place,
		realWidget
	}

	widgets.musicDisplay = {}
	function widgets.musicDisplay.toggle()
		if not musicDisplay.visible then
			awful.placement.under_mouse(musicDisplay)
		end
		musicDisplay.visible = not musicDisplay.visible -- invert
	end
end

do
	local volSliderBack = wibox.widget {
		widget = wibox.widget.progressbar,
		border_color = beautiful.fg_sec,
		border_width = 1,
		forced_height = 18,
		paddings = 4,
		background_color = beautiful.bg_normal,
		max_value = 100,
		shape = base.shape,
		bar_shape = base.shape
	}

	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = volSliderBack.forced_height,
		bar_color = '#00000000',
	}

	local function setupSlider()
		volSliderBack.color = string.format('linear:0,0:%s,0:0,%s:%s,%s', math.floor(slider.value), base.gradientColors[1], math.floor(slider.value), base.gradientColors[2])
		volSliderBack.value = slider.value
	end

	vol.get_volume_state(function(volume)
		slider.value = volume
		setupSlider()
	end)

	slider:connect_signal('property::value', function()
		vol.set(slider.value)
		setupSlider()
	end)

	widgets.volslider = wibox.widget {
		layout = wibox.layout.stack,
		volSliderBack,
		{
			layout = wibox.container.place,
			halign = 'center',
			valign = 'center',
			{
				widget = wibox.container.margin,
				top = 2, bottom = 2, left = 2, right = 2,
				slider
			}
		}
	}
end

do
	local control = wibox {
		width = dpi(480),
		height = dpi(180),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		{
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, false, true, base.rad) end,
			bg = beautiful.bg_normal,
			widget = wibox.container.background,
			forced_width = control.width - (base.width * 2),
			forced_height = control.height,
			{
				widget = wibox.container.margin,
				top = 20, left = 20, right = 20, bottom = 20,
				{
					layout = wibox.layout.fixed.vertical,
					spacing = 18,
					widgets.volslider
				}
			}
		},
		base.sideDecor {
			h = 180,
			position = 'right'
		},
	}

	control:setup {
		layout = wibox.container.place,
		realWidget
	}

	widgets.controlCenter = {}
	function widgets.controlCenter.toggle()
		if not control.visible then
			awful.placement.top_right(control, { margins = { top = dpi(beautiful.topbar_height) + beautiful.useless_gap * 2, right = dpi(12) }, parent = s })
		end

		control.visible = not control.visible
	end
end

do
	local powerMenu = wibox {
		width = dpi(520),
		height = dpi(200),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}
	local function hide()
		powerMenu.visible = false
		awful.keygrabber.stop()
	end

	local powerText = wibox.widget {
		widget = wibox.widget.textbox,
		markup = helpers.colorize_text('Power Options Menu', beautiful.fg_sec),
		font = 'SF Pro Display 16'
	}
	local function setupDisplayers(set)
		for i, widget in ipairs(set) do
			if i % 2 ~= 0 then
				widget:connect_signal('mouse::enter', function() powerText.markup = helpers.colorize_text(set[i + 1], beautiful.fg_sec) end)
			end
		end
	end

	local iconFont = 'Font Awesome 6 Free 58'
	local buttonColor = beautiful.fg_normal
	local logout = button(buttonColor, '', iconFont)

	logout:connect_signal('button::press', function()
		awesome.quit()
		hide()
	end)

	local shutdown = button(buttonColor, '', iconFont)
	shutdown:connect_signal('button::press', function()
		awful.spawn 'poweroff'
		hide()
	end)
	local restart = button(buttonColor, '', iconFont)
	restart:connect_signal('button::press', function()
		awful.spawn 'reboot'
		hide()
	end)
	local sleep = button(buttonColor, '', iconFont)
	sleep:connect_signal('button::press', function()
		awful.spawn 'systemctl suspend'
		hide()
	end)
	setupDisplayers {
		logout,
		'Logout',
		shutdown,
		'Shutdown',
		restart,
		'Restart',
		sleep,
		'Sleep'
	}

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		{
			widget = wibox.container.background,
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, false, true, base.rad) end,
			bg = bgcolor,
			forced_width = powerMenu.width - dpi(base.width),
			{
				widget = wibox.container.margin,
				left = dpi(base.width),
				{
					layout = wibox.layout.align.vertical,
					{
						layout = wibox.container.place
					},
					{
						layout = wibox.layout.flex.horizontal,
						logout,
						shutdown,
						restart,
						sleep
					},
					{
						widget = wibox.container.margin,
						bottom = 12,
						right = dpi(base.width) / 2,
						{
							layout = wibox.layout.fixed.vertical,
							spacing = 12,
							{
								widget = wibox.widget.separator,
								forced_height = 1,
								thickness = 1,
								orientation = 'horizontal',
								color = beautiful.fg_sec
							},
							{
								layout = wibox.layout.align.horizontal,
								expand = 'none',
								{
									layout = wibox.layout.fixed.horizontal,
									spacing = 8,
									{
										layout = wibox.container.place,
										valign = 'center',
										{
											widget = wibox.container.constraint,
											width = 22,
											w.imgwidget 'grey-logo.png'
										}
									},
									powerText
								},
								--[[
								{
									layout = wibox.container.place
								},
								{
									widget = wibox.widget.textbox,
									markup = helpers.colorize_text(string.format('Goodbye, %s. What would you like to do?', os.getenv 'USER' or user), beautiful.fg_sec)
								}
								]]--
							}
						}
					}
				}
			}
		},
		base.sideDecor {
			h = powerMenu.height,
			position = 'right',
			bg = bgcolor
		},
	}
	realWidget:connect_signal('mouse::leave', function()
		powerText.markup = helpers.colorize_text('Power Options Menu', beautiful.fg_sec)
	end)

	powerMenu:setup {
		layout = wibox.container.place,
		realWidget
	}

	widgets.powerMenu = {}
	function widgets.powerMenu.toggle()
		if not powerMenu.visible then
			awful.placement.centered(powerMenu, {parent = awful.screen.focused()})
			awful.keygrabber.run(function(_, _, event)
				if event == 'release' then return end
				hide()
			end)
		end

		powerMenu.visible = not powerMenu.visible
	end
end

return widgets
