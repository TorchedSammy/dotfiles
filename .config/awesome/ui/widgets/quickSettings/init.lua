local awful = require 'awful'
local beautiful = require 'beautiful'
local base = require 'ui.extras.syntax.base'
local dpi = beautiful.dpi
local gears = require 'gears'
local harmony = require 'ui.components.harmony'
local helpers = require 'helpers'
local rubato = require 'libs.rubato'
local settings = require 'conf.settings'
local wibox = require 'wibox'
local w = require 'ui.widgets'
local sfx = require 'modules.sfx'

local bgcolor = beautiful.bg_popup
local btnSize = dpi(32)
local quickSettingsMargin = dpi(20)
local toggleSpacing = dpi(16)
local widgets = {}
local centers = {
	wifi = require 'ui.widgets.quickSettings.wifi',
	battery = require 'ui.widgets.quickSettings.battery',
	bluetooth = require 'ui.widgets.quickSettings.bluetooth',
}

local toggleLayout
local controlLayout
local contentLayout
local contentLabelLayout

local quickSettingsAnimator = rubato.timed {
	duration = 0.2,
	rate = 60,
	subscribed = function(sf)
		if controlLayout then
			controlLayout:set_scroll_factor(sf)
		end
	end,
	easing = rubato.quadratic
}

local function contentBackCallback()
	quickSettingsAnimator.target = 0
	contentLayout:reset()
end

local contentLabel = harmony.titlebar('Content', {
	before = w.button('arrow-left', {
		bg = beautiful.bg_sec,
		size = beautiful.dpi(20),
		onClick = contentBackCallback
	})
})

local quickSettingsTitle, qstHeight = harmony.titlebar 'Quick Settings'
local quickSettings = wibox {
	height = dpi(420) + qstHeight,
	width = dpi(460),
	bg = '#00000000',
	shape = gears.shape.rectangle,
	ontop = true,
	visible = false
}

local function createToggle(type)
	local ok, controlModule = pcall(require, string.format('ui.widgets.quickSettings.%s', type))
	local control = ok and controlModule or {
		enabled = function() return false end,
		toggle = function() return false end,
		status = function() return false, '' end,
	}

	local toggleFgColor = beautiful.fg_normal
	local toggleMargin = beautiful.dpi(10)

	local icon = w.icon(control.enabled() and type or type .. '-off', {size = btnSize, color = toggleFgColor})
	local rightIcon = w.icon('arrow-right', {size = btnSize, color = toggleFgColor})

	local _, textStatus = control.status()
	local wid = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = beautiful.dpi(8),
		{	
			widget = wibox.container.constraint,
			height = dpi(55),
			width = dpi(110),
			--width = ((quickSettings.width - quickSettingsMargin - (toggleSpacing * dpi(3))) / 3) + btnSize / 3,
			strategy = 'exact',
			{
				widget = wibox.container.background,
				shape = helpers.rrect(beautiful.radius),
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
						control.display and rightIcon or nil
					}
				}
			}
		},
		{
			layout = wibox.container.place,
			{
				widget = wibox.widget.textbox,
				text = textStatus,
				font = beautiful.font:gsub('%d+$', '14')
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
	local function displayControls()
		contentLabel:text(control.title)
		quickSettingsAnimator.target = 1
		control.display(contentLayout)
	end

	icon.buttons = {
		awful.button({}, 1, function()
			if control.toggle then
				local controlOn = control.toggle()
				setToggleBackground(controlOn)
				if controlOn then
					icon.icon = type
				else
					icon.icon = type .. '-off'
				end
			else
				displayControls()
			end
		end),
	}
	rightIcon.buttons = {
		awful.button({}, 1, function()
			displayControls()
		end)
	}

	toggleLayout:add(wid)
end

do
	local realWidget = wibox.widget {
		widget = wibox.container.background,
		bg = bgcolor,
		forced_width = quickSettings.width,
		forced_height = quickSettings.height,
		shape = helpers.rrect(beautiful.radius or base.radius),
		{
			layout = wibox.layout.overflow.horizontal,
			scrollbar_enabled = false,
			id = 'control',
			{
				widget = wibox.container.constraint,
				strategy = 'exact',
				width = quickSettings.width,
				{
					layout = wibox.layout.fixed.vertical,
					quickSettingsTitle,
					{
						widget = wibox.container.margin,
						margins = quickSettingsMargin,
						{
							layout = wibox.layout.fixed.vertical,
							spacing = quickSettingsMargin * 2,
							spacing_widget = {
								widget = wibox.widget.separator,
								thickness = beautiful.dpi(4),
								color = beautiful.bg_sec
							},
							{
								layout = wibox.layout.align.horizontal,
								{
									layout = wibox.layout.fixed.horizontal,
									spacing = quickSettingsMargin,
									{
										w.imgwidget('avatar.jpg', {
											clip_shape = gears.shape.circle
										}),
										widget = wibox.container.constraint,
										strategy = 'exact',
										width = beautiful.dpi(68),
										height = beautiful.dpi(68)
									},
									{
										widget = wibox.container.place,
										{
											layout = wibox.layout.fixed.vertical,
											w.coloredText(os.getenv 'USER', beautiful.fg_normal),
											{
												widget = wibox.widget.textbox,
												markup = helpers.colorize_text('up 10 hours, 23 minutes', beautiful.fg_sec)
											}
										}
									},
								},
								wibox.widget.base.make_widget(),
								{
									widget = wibox.container.place,
									halign = 'right',
									--[[
									w.button('power2', {
										bg = beautiful.bg_sec,
									})
									]]--
								}
							},
							{
								layout = wibox.layout.grid,
								horizontal_spacing = toggleSpacing,
								vertical_spacing = quickSettingsMargin,
								forced_num_cols = 3,
								homogeneous = true,
								expand = true,
								id = 'toggles'
							}
						}
					}
				},
			},
				{
					widget = wibox.container.constraint,
					strategy = 'exact',
					width = quickSettings.width,
					{
						layout = wibox.layout.fixed.vertical,
						contentLabel,
						{
							widget = wibox.container.margin,
							margins = quickSettingsMargin,
							{
								layout = wibox.layout.overflow.vertical,
								forced_width = quickSettings.width,
								id = 'content'
							}
						}
					}
				}
		}
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
	createToggle 'battery'
	createToggle 'coffee'
	createToggle 'focus'
	createToggle 'compositor'

	quickSettings:setup{
		layout = wibox.container.place,
		realWidget
	}

--[[
	local scr = awful.screen.focused()
	local animator = rubato.timed {
		duration = 0.4,
		rate = 60,
		subscribed = function(y)
			quickSettings.y = y
		end,
		pos = scr.geometry.height,
		easing = rubato.linear
	}

	function doPlacement()
		awful.placement.bottom_right(quickSettings, {
			margins = {
				right = beautiful.useless_gap * dpi(2),
				bottom = settings.noAnimate and beautiful.wibar_height + (beautiful.useless_gap * dpi(2)) or -quickSettings.height
			},
			parent = awful.screen.focused()
		})
	end
	doPlacement()
	if not settings.noAnimate then quickSettings.visible = true end

	local quickSettingsOpen
	widgets.quickSettings = {}
	function widgets.quickSettings.toggle()
		doPlacement()
		if settings.noAnimate then
			quickSettings.visible = not quickSettings.visible
		else
			if quickSettingsOpen then
				animator.target = scr.geometry.height
			else
				animator.target = scr.geometry.height - (beautiful.wibar_height + (beautiful.useless_gap * dpi(2))) - quickSettings.height
			end
		end

		quickSettingsOpen = not quickSettingsOpen
	end

	if settings.noAnimate then
		helpers.hideOnClick(quickSettings)
	else
		helpers.hideOnClick(quickSettings, settings.noAnimate and nil or function()
			if quickSettingsOpen then
				widgets.quickSettings.toggle()
				contentBackCallback()
			end
		end)
	end
	]]

	helpers.slidePlacement(quickSettings, {
		placement = 'bottom_right',
		toggler = function(open)
			if open then
				contentBackCallback()
			end
		end
	})
end

return quickSettings
