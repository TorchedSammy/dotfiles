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
local util = require 'ui.widgets.quickSettings.util'

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

-- stop quick settings from scrolling
local overflow = wibox.layout.overflow.horizontal()
function overflow:scroll() end

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

local function setupContentLayout()
	contentLayout:reset()
	contentLayout.scrollbar_widget = wibox.widget {
		widget = wibox.widget.separator,
		shape = gears.shape.rounded_bar,
		color = beautiful.accent
	}
end

local function contentBackCallback()
	quickSettingsAnimator.target = 0
	setupContentLayout()
end

local contentLabel = harmony.titlebar('Content', {
	before = w.button('arrow-left', {
		bg = beautiful.bg_sec,
		size = beautiful.dpi(20),
		onClick = contentBackCallback
	})
})

local quickSettingsTitle, qstHeight = harmony.titlebar 'Quick Settings'
local quickSettings = helpers.aaWibox {
	height = dpi(500) + qstHeight,
	width = dpi(460),
	bg = bgcolor,
	rrectRadius = beautiful.radius,
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

	local toggleBg = beautiful.accent
	local toggleBgOff = helpers.shiftColor(beautiful.xcolor9, 3)

	local toggleFgColor = beautiful.bg_popup
	local toggleFgColorOff = beautiful.fg_normal
	local toggleMargin = beautiful.dpi(10)

	local on, textStatus = control.status()
	local icon = w.icon(control.enabled() and type or type .. '-off', {size = btnSize, color = on and toggleFgColor or toggleFgColorOff})
	local rightIcon = w.icon('arrow-right', {size = btnSize / 1.5, color = on and toggleFgColor or toggleFgColorOff})

	local status = wibox.widget {
		widget = wibox.widget.textbox,
		text = textStatus,
		font = beautiful.font:gsub('%d+$', '14')
	}

	local wid = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = beautiful.dpi(8),
		{	
			widget = wibox.container.constraint,
			height = dpi(58),
			--width = dpi(90),
			--width = ((quickSettings.width - quickSettingsMargin - (toggleSpacing * dpi(3))) / 3) + btnSize / 3,
			strategy = 'exact',
			{
				widget = wibox.container.background,
				shape = helpers.rrect(15),
				id = 'bg',
				{
					widget = wibox.container.margin,
					left = toggleMargin, right = toggleMargin,
					{
							layout = wibox.layout.stack,
							--spacing = beautiful.dpi(24),
							{
								widget = wibox.container.place,
								icon,
							},
							{
								widget = wibox.container.place,
								halign = 'right',
								control.display and rightIcon or nil
							},
					}
				}
			}
		},
		{
			layout = wibox.container.place,
			status
		}
	}
	local function setToggleBackground(toggledOn)
		helpers.transitionColor {
			old = toggledOn and toggleBgOff or toggleBg,
			new = not toggledOn and toggleBgOff or toggleBg,
			transformer = function(col)
				wid:get_children_by_id 'bg'[1].bg = col
			end,
			duration = 0.5
		}

		helpers.transitionColor {
			old = toggledOn and toggleFgColorOff or toggleFgColor,
			new = not toggledOn and toggleFgColorOff or toggleFgColor,
			transformer = function(col)
				icon.color = col
				rightIcon.color = col
			end,
			duration = 0.5
		}
	end

	setToggleBackground(control.enabled())
	local function displayControls()
		contentLabel:text(control.title)
		quickSettingsAnimator.target = 1
		control.display(contentLayout)
	end

	local function setupButtonState(on)
		setToggleBackground(on)
		if on then
			--icon.icon = type
		else
			--icon.icon = type .. '-off'
		end
	end

	local function toggle()
		if control.toggle then
			local controlOn = control.toggle()
			if controlOn == nil then return end

			setupButtonState(controlOn)
		else
			displayControls()
		end
	end

	util.connectSignal(type, 'toggle', setupButtonState)
	util.connectSignal(type, 'status', function(statText)
		status.text = statText
	end)

	icon.buttons = {
		awful.button({}, 1, toggle),
	}
	rightIcon.buttons = {
		awful.button({}, 1, function()
			displayControls()
		end)
	}

	if control.fetch then
		control.fetch()
	end

	toggleLayout:add(wid)
end

do
	local volSlider = harmony.slider {
		icon = 'volume2'
	}
	local brightSlider = harmony.slider {
		icon = 'brightness'
	}

	local realWidget = wibox.widget {
			layout = overflow,
			scrollbar_enabled = false,
			forced_width = quickSettings.width,
			forced_height = quickSettings.height,
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
							spacing = quickSettingsMargin * beautiful.dpi(2),
							spacing_widget = {
								widget = wibox.widget.separator,
								thickness = beautiful.dpi(3),
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
											{
												widget = wibox.widget.textbox,
												text = os.getenv 'USER',
												font = beautiful.fontName .. ' Bold 12',
											},
											{
												widget = wibox.widget.textbox,
												markup = helpers.colorize_text('up 10 hours, 23 minutes', beautiful.fg_sec),
												font = beautiful.fontName .. ' Bold 12',
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
							},
							{
								layout = wibox.layout.fixed.vertical,
								spacing = quickSettingsMargin,
								brightSlider,
								volSlider
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

	awesome.connect_signal('syntax::volume', function(volume, muted, init)
		volSlider.icon = muted and 'volume-muted' or 'volume2'
		volSlider.value = volume
		volSlider.color = muted and beautiful.xcolor12 or beautiful.accent
	end)


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

	setupContentLayout()

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
