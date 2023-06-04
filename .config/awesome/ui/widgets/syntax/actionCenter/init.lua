local awful = require 'awful'
local beautiful = require 'beautiful'
local base = require 'ui.components.syntax.base'
local dpi = beautiful.dpi
local gears = require 'gears'
local helpers = require 'helpers'
local rubato = require 'libs.rubato'
local settings = require 'conf.settings'
local wibox = require 'wibox'
local w = require 'ui.widgets'
local sfx = require 'modules.sfx'

local bgcolor = beautiful.bg_sec
local btnSize = dpi(32)
local actionCenterMargin = dpi(12)
local toggleSpacing = dpi(36)
local widgets = {}
local centers = {
	wifi = require 'ui.widgets.syntax.actionCenter.wifi'
}

local toggleLayout
local controlLayout
local contentLayout
local contentLabelLayout

local actionCenter = wibox {
	height = dpi(420),
	width = dpi(460),
	bg = '#00000000',
	shape = gears.shape.rectangle,
	ontop = true,
	visible = false
}

local actionCenterAnimator = rubato.timed {
	intro = 0.02,
	duration = 0.04,
	override_dt = true,
	subscribed = function(sf)
		if controlLayout then
			controlLayout:set_scroll_factor(sf)
		end
	end
}

local function createToggle(type)
	local control = centers[type] or {
		enabled = function() return false end,
		toggle = function() return false end,
	}

	local toggleFgColor = beautiful.fg_normal
	local toggleMargin = beautiful.dpi(10)

	local icon = w.icon(control.enabled() and type or type .. '-off', {size = btnSize, color = toggleFgColor})
	local rightIcon = w.icon('arrow-right', {size = btnSize, color = toggleFgColor})

	local wid = wibox.widget {
		widget = wibox.container.constraint,
		height = dpi(50),
		width = ((actionCenter.width - actionCenterMargin - (toggleSpacing * dpi(3))) / 3) + btnSize / 3,
		strategy = 'exact',
		{
			widget = wibox.container.background,
			shape = helpers.rrect(base.radius),
			id = 'bg',
			{
				widget = wibox.container.margin,
				left = toggleMargin, right = toggleMargin,
				{
					layout = wibox.layout.align.horizontal,
					spacing = beautiful.dpi(24),
					{
						widget = wibox.container.place
					},
					icon,
					rightIcon
				}
			}
		}
	}
	local function setToggleBackground(toggledOn)
		if toggledOn then
			wid:get_children_by_id 'bg'[1].bg = beautiful.accent
		else
			wid:get_children_by_id 'bg'[1].bg = beautiful.xcolor9
		end
	end

	setToggleBackground(control.enabled())

	icon.buttons = {
		awful.button({}, 1, function()
			local controlOn = control.toggle()
			setToggleBackground(controlOn)
			if controlOn then
				icon.icon = type
			else
				icon.icon = type .. '-off'
			end
		end),
	}
	rightIcon.buttons = {
		awful.button({}, 1, function()
			contentLabelLayout.markup = helpers.colorize_text(control.title, beautiful.fg_normal)
			actionCenterAnimator.target = 1
			control.display(contentLayout)
		end)
	}

	toggleLayout:add(wid)
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
		duration = 0.2,
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
		widget = wibox.container.constraint,
		height = beautiful.dpi(5),
		{
			layout = wibox.layout.stack,
			progress,
			slider
		}
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

function createSlider(name)
	local sl, slider, progress = slider {width = 460 - 24, onChange = sliderControllers[name].set}
	sliderControllers[name].get(function(v)
		slider.value = v
	end)

	awesome.connect_signal('syntax::' .. name, function(vol)
		slider.value = vol
	end)

	local wid = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		spacing = beautiful.dpi(6),

		w.icon(name),
		sl
	}

	return setmetatable({}, {
		__index = function(_, k)
			return wid[k]
		end,
		__newindex = function(_, k, v)
			if k == 'value' then
				slider.value = v
			end
		end
	})
end

do
	local contentBack = w.button('arrow-left', {bg = bgcolor, size = beautiful.dpi(32)})
	contentBack.buttons = {
		awful.button({}, 1, function()
			actionCenterAnimator.target = 0
			contentLayout:reset()
		end)
	}

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		{
			widget = wibox.container.background,
			bg = bgcolor,
			forced_width = actionCenter.width,
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, true, true, base.radius) end,
			{
				layout = wibox.layout.align.vertical,
				{
					layout = wibox.layout.overflow.horizontal,
					scrollbar_enabled = false,
					id = 'control',
					{
						widget = wibox.container.constraint,
						strategy = 'exact',
						width = actionCenter.width,
						{
							widget = wibox.container.margin,
							margins = actionCenterMargin,
							{
								layout = wibox.layout.fixed.vertical,
								spacing = actionCenterMargin,
								{
									widget = wibox.widget.textbox,
									markup = helpers.colorize_text('Action Center', beautiful.fg_normal),
									font = beautiful.font:gsub('%d+$', '24')
								},
								{
									layout = wibox.layout.grid,
									spacing = toggleSpacing,
									forced_num_cols = 3,
									id = 'toggles',
								},
								createSlider 'volume',
								createSlider 'brightness'
							}
						}
					},
					{
						widget = wibox.container.constraint,
						strategy = 'exact',
						width = actionCenter.width,
						{
							widget = wibox.container.margin,
							margins = actionCenterMargin,
							{
								layout = wibox.layout.fixed.vertical,
								{
									layout = wibox.layout.align.horizontal,
									{
										layout = wibox.container.place,
										valign = 'center',
										{
											layout = wibox.layout.fixed.horizontal,
											spacing = beautiful.dpi(4),
											contentBack,
											{
												widget = wibox.widget.textbox,
												font = beautiful.font:gsub('%d+$', '24'),
												id = 'contentLabel',
												valign = 'center'
											}
										}
									},
									{
										layout = wibox.container.place,
									}
								},
								{
									layout = wibox.layout.overflow.vertical,
									forced_width = actionCenter.width,
									id = 'content'
								}
							}
						}
					}
				},
				{
					layout = wibox.layout.align.horizontal,
					expand = 'none',
				}
			}
		},
	}

	-- for fancy scrolling between toggles and controls
	controlLayout = realWidget:get_children_by_id 'control'[1]
	-- toggles
	toggleLayout = realWidget:get_children_by_id 'toggles'[1]
	-- control content (example list of wifi networks)
	contentLayout = realWidget:get_children_by_id 'content'[1]
	contentLabelLayout = realWidget:get_children_by_id 'contentLabel'[1]
	controlLayout:set_step(1)
	createToggle 'wifi'
	createToggle 'bluetooth'
	createToggle 'coffee'
	createToggle 'coffee'
	createToggle 'coffee'
	createToggle 'coffee'
	createToggle 'coffee'
	createToggle 'coffee'
	createToggle 'coffee'

	actionCenter:setup {
		layout = wibox.layout.stack,
		base.sideDecor {
			h = actionCenter.width,
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
		duration = 0.4,
		rate = 60,
		subscribed = function(y)
			actionCenter.y = y
		end,
		pos = scr.geometry.height,
		easing = rubato.linear
	}

	function doPlacement()
		awful.placement.bottom_right(actionCenter, {
			margins = {
				right = beautiful.useless_gap * dpi(2),
				bottom = settings.noAnimate and beautiful.wibar_height + (beautiful.useless_gap * dpi(2)) or -actionCenter.height
			},
			parent = awful.screen.focused()
		})
	end
	doPlacement()
	if not settings.noAnimate then actionCenter.visible = true end

	local actionCenterOpen
	widgets.actionCenter = {}
	function widgets.actionCenter.toggle()
		if settings.noAnimate then
			doPlacement()
			actionCenter.visible = not actionCenter.visible
		else
			if actionCenterOpen then
				animator.target = scr.geometry.height
			else
				animator.target = scr.geometry.height - (beautiful.wibar_height + (beautiful.useless_gap * dpi(2))) - actionCenter.height
			end
		end

		actionCenterOpen = not actionCenterOpen
	end

	if settings.noAnimate then
		helpers.hideOnClick(actionCenter)
	else
		helpers.hideOnClick(actionCenter, settings.noAnimate and nil or function()
			if actionCenterOpen then
				widgets.actionCenter.toggle()
			end
		end)
	end
end

return widgets.actionCenter
