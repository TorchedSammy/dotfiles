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
	local startMenu = wibox {
		height = dpi(580),
		width = dpi(460),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}

	local result = {}
	local allApps = {}
	local appList = wibox.layout.overflow.vertical()
	appList.spacing = 1
	appList.step = 65
	appList.scrollbar_widget = {
		{
			widget = wibox.widget.separator,
			shape = gears.shape.rounded_bar,
			color = beautiful.xcolor11
		},
		widget = wibox.container.margin,
		left = dpi(5),
	}
	appList.scrollbar_width = dpi(14)

	--menugen.generate = function() end -- TODO: remove (stop using menugen)
	menugen.generate(function(entries)
		for k, v in pairs(menugen.all_categories) do
			table.insert(result, { k, {}, v.icon })
		end

		for k, v in pairs(entries) do
			for _, cat in pairs(result) do
				if cat[1] == v.category then
					table.insert(cat[2], {v.name, v.cmdline, v.icon})
					allApps[v.name] = {v.cmdline, v.icon}
					break
				end
			end
		end

		local function pairsByKeys (t, f)
			local a = {}
			for n in pairs(t) do table.insert(a, n) end
			table.sort(a, f)
			local i = 0
			local iter = function ()
				i = i + 1
				if a[i] == nil then return nil
				else return a[i], t[a[i]]
				end
			end
			return iter
		end

--		for i = #result, 1, -1 do
--			local v = result[i]
--			if #v[2] == 0 then
--				-- Remove unused categories
--				table.remove(result, i)
--			else
--				table.sort(v[2], function(a, b) return string.lower(a[1]) < string.lower(b[1]) end)
--				v[1] = menugen.all_categories[v[1]].name
--			end
--		end

		for name, props in pairsByKeys(allApps, function(a, b) return string.lower(a) < string.lower(b) end) do
			local wid = wibox.widget {
				widget = wibox.container.background,
				shape = helpers.rrect(base.radius),
				id = 'bg',
				bg = bgcolor,
				{
					widget = wibox.container.margin,
					margins = dpi(4),
					{	
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(8),
						{
							{
								widget = wibox.widget.imagebox,
								image = props[2]
							},
							widget = wibox.container.constraint,
							strategy = 'exact',
							width = 32,
							height = 32
						},
						{
							widget = wibox.widget.textbox,
							align = 'center',
							halign = 'center',
							valign = 'center',
							markup = name
						}
					}
				}
			}
			wid.buttons = {
				awful.button({}, 1, function()
					awful.spawn(props[1])
					widgets.startMenu.toggle()
				end)
			}
			helpers.displayClickable(wid, {bg = bgcolor})
			appList:add(wid)
		end
	end)

	local power = button(buttonColor, 'power2', beautiful.dpi(18))
	power:connect_signal('button::press', function()
		widgets.powerMenu.toggle()
	end)

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		{
			widget = wibox.container.background,
			bg = bgcolor,
			forced_width = startMenu.width,
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, true, true, base.radius) end,
			{
				widget = wibox.container.margin,
				margins = dpi(5),
				{
					layout = wibox.layout.align.vertical,
					{
						widget = wibox.widget.textbox,
						markup = helpers.colorize_text('Applications', beautiful.fg_normal),
						font = beautiful.font:gsub('%d+$', '24')
					},
					{
						widget = wibox.container.margin,
						bottom = dpi(5),
						appList
					},
					{
						layout = wibox.layout.align.horizontal,
						expand = 'none',
						{
							layout = wibox.layout.fixed.horizontal,
							spacing = dpi(5),
							{
								w.imgwidget('avatar.jpg', {
									clip_shape = gears.shape.circle
								}),
								widget = wibox.container.constraint,
								strategy = 'exact',
								width = 24,
								height = 24
							},
							{
								widget = wibox.widget.textbox,
								text = os.getenv 'USER'
							}
						},
						{
							layout = wibox.layout.fixed.horizontal,
						},
						power
					}
				}
			}
		},
	}

	startMenu:setup {
		layout = wibox.layout.stack,
		base.sideDecor {
			h = startMenu.height,
			position = 'top',
			bg = bgcolor,
			emptyLen = base.width / dpi(2)
		},
		{
			widget = wibox.container.margin,
			top = base.width / dpi(2),
			realWidget,
		}
	}

	local scr = awful.screen.focused()
	local animator = rubato.timed {
		duration = 0.3,
		rate = 60,
		subscribed = function(y)
			startMenu.y = y
		end,
		pos = scr.geometry.height,
		easing = rubato.linear
	}

	local function doPlacement()
		awful.placement.bottom_left(startMenu, {
			margins = {
				left = beautiful.useless_gap * dpi(2),
				bottom = settings.noAnimate and beautiful.wibar_height + beautiful.useless_gap * dpi(2) or -startMenu.height
			},
			parent = awful.screen.focused()
		})
	end
	doPlacement()
	if not settings.noAnimate then startMenu.visible = true end

	local startMenuOpen = false
	widgets.startMenu = {}
	function widgets.startMenu.toggle()
		appList.scroll_factor = 0
		if not startMenuOpen then
			doPlacement()
		end

		if settings.noAnimate then
			startMenu.visible = not startMenu.visible
		else
			if startMenuOpen then
				animator.target = scr.geometry.height
			else
				animator.target = scr.geometry.height - (beautiful.wibar_height + beautiful.useless_gap * dpi(2)) - startMenu.height
			end
		end
		startMenuOpen = not startMenuOpen
	end

	if settings.noAnimate then
		helpers.hideOnClick(startMenu)
	else
		helpers.hideOnClick(startMenu, settings.noAnimate and nil or function()
			if startMenuOpen then
				widgets.startMenu.toggle()
			end
		end)
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
		capsWidget.visible = capsStatus
	end
end

widgets.quickSettings = require 'ui.widgets.syntax.quickSettings'

return widgets
