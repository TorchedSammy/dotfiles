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

local bgcolor = beautiful.bg_sec
local btnSize = beautiful.dpi(32)
local widgets = {}
local centers = {
	wifi = require 'ui.widgets.syntax.actionCenter.wifi'
}

local toggleLayout
local controlLayout
local contentLayout
local contentLabelLayout

local actionCenter = wibox {
	height = dpi(580),
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
		width = dpi(72 + (btnSize * beautiful.dpi(3))),
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
				icon.icon = 'wifi'
			else
				icon.icon = 'wifi-off'
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

do
	helpers.hideOnClick(actionCenter)

	local contentBack = w.button('arrow-left', {bg = bgcolor, size = beautiful.dpi(32)})
	contentBack.buttons = {
		awful.button({}, 1, function()
			actionCenterAnimator.target = 0
			contentLayout:reset()
		end)
	}

	local actionCenterMargin = beautiful.dpi(12)
	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		{
			widget = wibox.container.background,
			bg = bgcolor,
			forced_width = actionCenter.width,
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
								spacing = beautiful.dpi(6),
								{
									widget = wibox.widget.textbox,
									markup = helpers.colorize_text('Action Center', beautiful.fg_normal),
									font = beautiful.font:gsub('%d+$', '24')
								},
								{
									layout = wibox.layout.grid,
									spacing = dpi(36),
									forced_num_cols = 3,
									id = 'toggles'
								}
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
	createToggle 'wifi'

	actionCenter:setup {
		layout = wibox.layout.stack,
		base.sideDecor {
			h = actionCenter.height,
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
		outro = 0.5,
		duration = 0.7,
		rate = 30,
		subscribed = function(y)
			actionCenter.y = y
		end,
		pos = scr.geometry.height + actionCenter.height,
		easing = rubato.quadratic
	}
	
	awful.placement.bottom_right(actionCenter, {
		margins = {
			right = beautiful.useless_gap * dpi(2),
			bottom = settings.noAnimate and beautiful.wibar_height + beautiful.useless_gap * dpi(2) or -actionCenter.height
		},
		parent = awful.screen.focused()
	})
	if not settings.noAnimate then actionCenter.visible = true end

	widgets.actionCenter = {}
	function widgets.actionCenter.toggle()
		if settings.noAnimate then
			actionCenter.visible = not actionCenter.visible
		else
			if actionCenter.y <= scr.geometry.height - actionCenter.height then
				animator.target = scr.geometry.height
			else
				animator.target = scr.geometry.height - (beautiful.wibar_height + beautiful.useless_gap * dpi(2)) - actionCenter.height
			end
		end
	end
end

return widgets.actionCenter
