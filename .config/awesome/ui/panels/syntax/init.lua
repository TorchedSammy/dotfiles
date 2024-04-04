local awful = require 'awful'
local base = require 'ui.extras.syntax.base'
local beautiful = require 'beautiful'
local bling = require 'libs.bling'
local dpi = beautiful.dpi
local gears = require 'gears'
local helpers = require 'helpers'
local wibox = require 'wibox'
local w = require 'ui.widgets'
local naughty = require 'naughty'
local menugen = require 'menubar.menu_gen'
local rubato = require 'libs.rubato'
local settings = require 'conf.settings'
local sfx = require 'modules.sfx'
local pctl = require 'modules.playerctl'
local syntax = require 'ui.components.syntax'

local bgcolor = beautiful.bg_sec
local playerctl = bling.signal.playerctl.lib()
local function button(color_focus, icon, size, shape)
	return w.button(icon, {bg = bgcolor, shape = shape, size = size})
end

local widgets = {}

do
	local music = require 'ui.widgets.musicDisplay'

	local musicDisplay = wibox {
		width = beautiful.dpi(480),
		height = beautiful.dpi(180),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}

	local musicWidget = music.new {
		bg = bgcolor,
		shape = function(crr, w, h)
			return gears.shape.partially_rounded_rect(crr, w, h, false, true, true, false, 6)
		end
	}
	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		base.sideDecor {
			h = music.height,
			bg = bgcolor
		},
		{
			widget = wibox.container.margin,
			left = -(base.widths.round - (base.widths.empty / 2)),
			musicWidget
		}
	}

	helpers.hideOnClick(musicDisplay)

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
		font = 'SF Pro Display 20'
	}
	local function setupDisplayers(set)
		for i, widget in ipairs(set) do
			if i % 2 ~= 0 then
				widget:connect_signal('mouse::enter', function() powerText.markup = helpers.colorize_text(set[i + 1], beautiful.fg_sec) end)
			end
		end
	end

	local logout = w.button('logout', {
		bg = bgcolor,
		size = beautiful.dpi(58),
		shape = helpers.rrect(base.radius),
		onClick = function()
			awesome.quit()
			hide()
	  end
	})
	local shutdown = w.button('power2', {
		bg = bgcolor,
		size = beautiful.dpi(58),
		shape = helpers.rrect(base.radius),
		onClick = function()
			awful.spawn 'poweroff'
			hide()
		end
	})
	local restart = w.button('restart', {
		bg = bgcolor,
		size = beautiful.dpi(58),
		shape = helpers.rrect(base.radius),
		onClick = function()
			awful.spawn 'reboot'
			hide()
		end
	})
	local sleep = w.button('sleep', {
		bg = bgcolor,
		size = beautiful.dpi(58),
		shape = helpers.rrect(base.radius),
		onClick = function()
			awful.spawn 'systemctl suspend'
			hide()
		end
	})

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
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, false, true, base.radius) end,
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
						widget = wibox.container.margin,
						top = beautiful.dpi(8), bottom = beautiful.dpi(8),
						{
							layout = wibox.layout.flex.horizontal,
							logout,
							shutdown,
							restart,
							sleep
						}
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

	helpers.hideOnClick(powerMenu)
end

do
	local sm = require 'ui.widgets.startMenu'
	local startMenu = sm.create {
		bg = bgcolor,
		shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, true, true, base.radius) end
	}
	sm.bindMethods(startMenu)
	
	widgets.startMenu = {}
	function widgets.startMenu.toggle()
		startMenu:toggle()
	end
end

function slider(opts, onChange)
	opts = opts or {}

	local progressShape = gears.shape.rounded_bar
	local progress = wibox.widget {
		widget = wibox.widget.progressbar,
		shape = progressShape,
		bar_shape = progressShape,
		background_color = beautiful.xcolor9,
		max_value = opts.max or 100,
		forced_height = beautiful.dpi(5),
		id = 'progress'
	}

	local function setupProgressColor(pos, length)
		local posFraction = (pos / length)
		local progressLength = opts.width
		local progressCur = posFraction * progressLength
		progress.color = string.format('linear:0,0:%s,0:0,%s:%s,%s', math.floor(beautiful.dpi(progressCur)), base.gradientColors[1], math.floor(beautiful.dpi(progressLength)), base.gradientColors[2])
		progress.value = pos
	end

	local progressAnimator = rubato.timed {
		duration = 0.3,
		rate = 60,
		subscribed = function(pos)
			setupProgressColor(pos, progress.max_value)
		end,
		pos = 0,
		easing = rubato.quadratic
	}

	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = progress.forced_height,
		bar_color = '#00000000',
		id = 'slider'
	}
	slider:connect_signal('property::value', function()
		progressAnimator.target = slider.value
		opts.onChange(slider.value)
	end)

	return wibox.widget {
		layout = wibox.layout.stack,
		progress,
		slider
	}, slider, progress
end

local sliderControllers = {
	volume = {
		set = sfx.setVolume,
		get = sfx.get_volume_state
	},
	brightness = {
		set = function() end,
		get = function() end
	}
}

function createSlider(name, opts)
	local sl, slider, progress = slider {width = opts.width, onChange = sliderControllers[name].set}
	sliderControllers[name].get(function(v)
		slider.value = v
	end)

	local wid = wibox.widget {
		widget = wibox.container.place,
		valign = 'center',
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = beautiful.dpi(8),
			w.icon(name, {size = beautiful.dpi(32)}),
			{
				layout = wibox.container.place,
				sl,
			}
		}
	}

	return setmetatable({}, {
		__index = function(_, k)
			return wid[k]
		end,
		__newindex = function(_, k, v)
			if k == 'value' then
				slider.value = v
			elseif k == 'max' then
				progress.max = v
				slider.maximum = v
			end
		end
	})
end

do
	local volumeDisplay = wibox {
		width = dpi(280),
		height = dpi(50),
		bg = '#00000000',
		ontop = true,
		visible = false
	}
	local sl = syntax.slider {
		width = volumeDisplay.width,
		height = beautiful.dpi(6),
		icon = 'volume',
		iconSize = beautiful.dpi(28),
		bg = beautiful.xcolor9,
		onChange = function(val)
			sfx.setVolume(val)
		end
	}
	--local sl = createSlider('volume', {width = volumeDisplay.width})

	local displayTimer = gears.timer {
		timeout = 2,
		single_shot = true,
		callback = function()
			volumeDisplay.visible = false
		end
	}

	local margins = beautiful.dpi(10)
	volumeDisplay:setup {
		layout = wibox.layout.fixed.vertical,
		base.sideDecor {
			h = volumeDisplay.width,
			bg = bgcolor,
			position = 'top',
			emptyLen = base.width / dpi(2)
		},
		{
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, true, false, base.radius) end,
			bg = bgcolor,
			widget = wibox.container.background,
			{
				widget = wibox.container.margin,
				top = margins - (base.width / dpi(2)),
				bottom = margins, left = margins, right = margins,
				sl
			}
		},
	}

	awesome.connect_signal('syntax::volume', function(volume, muted)
		if volumeDisplay.visible then
			displayTimer:stop()
		end
		displayTimer:start()
		sl.value = volume
		sl.icon = muted and 'volume-muted' or 'volume'
		sl.muted = muted

		awful.placement.bottom(volumeDisplay, { margins = { bottom = beautiful.wibar_height + (beautiful.useless_gap * dpi(2)) }, parent = awful.screen.focused() })
		volumeDisplay.visible = true
	end)
end

do
	widgets.capsIndicator = {}
	local capsIndicator = wibox {
		width = dpi(280),
		height = dpi(75),
		bg = '#00000000',
		ontop = true,
		visible = false
	}

	local displayTimer = gears.timer {
		timeout = 2,
		single_shot = true,
		callback = function()
			capsIndicator.visible = false
		end
	}

	function widgets.capsIndicator.display(capsStatus)
		local margins = beautiful.dpi(10)
		local realWidget = wibox.widget {
			layout = wibox.layout.fixed.vertical,
			base.sideDecor {
				h = capsIndicator.width,
				bg = bgcolor,
				position = 'top',
				emptyLen = base.width / dpi(2)
			},
			{
				shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, true, false, base.radius) end,
				bg = bgcolor,
				widget = wibox.container.background,
				{
					widget = wibox.container.margin,
					margins = margins,
					{
						widget = wibox.container.place,
						valign = 'center',
						{
							layout = wibox.layout.fixed.horizontal,
							spacing = beautiful.dpi(6),

							w.icon(capsStatus and 'caps-on' or 'caps-off', {size = beautiful.dpi(32)}),
							{
								font = beautiful.font:gsub('%d+$', '24'),
								widget = wibox.widget.textbox,
								text = capsStatus and 'Caps Lock On' or 'Caps Lock Off'
							}
						}
					}
				}
			},
		}

		capsIndicator:setup {
			layout = wibox.container.place,
			realWidget
		}

		if capsIndicator.visible then
			displayTimer:stop()
		end
		displayTimer:start()

		awful.placement.bottom(capsIndicator, { margins = { bottom = beautiful.wibar_height + (beautiful.useless_gap * dpi(2)) }, parent = awful.screen.focused() })
		capsIndicator.visible = true
	end
end

do
	widgets.caps = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		visible = true,
		w.icon('caps-on', {
			size = beautiful.dpi(24),
			color = helpers.invertColor(beautiful.fg_normal)
		}),
		{
			font = beautiful.font:gsub('%d+$', '12'),
			widget = wibox.widget.textbox,
			text = 'Caps Lock On',
			valign = 'center'
		}
	}

	function widgets.caps.display(capsStatus)
		widgets.caps.visible = capsStatus
	end
end

widgets.quickSettings = require 'ui.widgets.syntax.quickSettings'

return widgets
