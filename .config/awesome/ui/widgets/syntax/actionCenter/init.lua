local awful = require 'awful'
local beautiful = require 'beautiful'
local base = require 'ui.components.syntax.base'
local dpi = beautiful.dpi
local gears = require 'gears'
local helpers = require 'helpers'
local rubato = require 'modules.rubato'
local settings = require 'conf.settings'
local wibox = require 'wibox'
local w = require 'ui.widgets'

local bgcolor = beautiful.bg_sec
local btnSize = beautiful.dpi(28)
local widgets = {}
local centers = {
	wifi = require 'ui.widgets.syntax.actionCenter.wifi'
}

local function createToggle(icon, opts)

	local wid = wibox.widget {
		widget = wibox.container.constraint,
		height = dpi(92),
		strategy = 'exact',
		{
			widget = wibox.container.background,
			shape = helpers.rrect(base.radius),
			bg = bgcolor,
			id = 'bg',
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.dpi(6),
				icon and icon or w.icon(icon, {size = btnSize}),
				{
					widget = wibox.widget.separator,
					forced_width = 2,
					thickness = 2,
					orientation = 'vertical',
					color = beautiful.bg_sec_opposite
				},
				w.icon('arrow-right', {size = btnSize})
			}
		}
	}

	return wid
end

do
	local actionCenter = wibox {
		height = dpi(580),
		width = dpi(460),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}
	helpers.hideOnClick(actionCenter)

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		{
			widget = wibox.container.background,
			bg = bgcolor,
			forced_width = actionCenter.width,
			{
				widget = wibox.container.margin,
				margins = dpi(5),
				{
					layout = wibox.layout.align.vertical,
					{
						widget = wibox.widget.textbox,
						markup = helpers.colorize_text('Action Center', beautiful.fg_normal),
						font = beautiful.font:gsub('%d+$', '24')
					},
					{
						widget = wibox.container.margin,
						bottom = dpi(5),
						{
							layout = wibox.layout.overflow.vertical,
							id = 'content'
						}
					},
					{
						layout = wibox.layout.align.horizontal,
						expand = 'none',
					}
				}
			}
		},
	}

	local layout = realWidget:get_children_by_id 'content'[1]
	local wifiIcon = w.icon(centers.wifi.enabled and 'wifi' or 'wifi-off', {size = btnSize})
	local wifiToggle = createToggle(wifiIcon)
	if centers.wifi.enabled then
		wifiToggle.bg = beautiful.accent
	end
	wifiToggle.buttons = {
		awful.button({}, 1, function()
			local wifiOn = centers.wifi.toggle()
			if wifiOn then
				wifiIcon.icon = 'wifi'
			else
				wifiIcon.icon = 'wifi-off'
			end
		end),
		awful.button({}, 3, function()
			centers.wifi.display(layout)
		end)
	}
	layout:add(wifiToggle)

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
