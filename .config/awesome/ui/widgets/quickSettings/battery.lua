local awful = require 'awful'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local gears = require 'gears'
local w = require 'ui.widgets'
local helpers = require 'helpers'
local battery = require 'modules.battery'
local syntax = require 'ui.components.syntax'
local M = {
	title = 'Battery',
}

local bgcolor = beautiful.bg_popup
local percentageBar = wibox.widget {
	widget = wibox.widget.progressbar,
	forced_height = beautiful.dpi(16),
	forced_width = beautiful.dpi(420),
	color = beautiful.accent,
	background_color = beautiful.xcolor10,
	shape = gears.shape.rounded_bar,
	max_value = 100
}

local function dropDown(default, items)
	-- items table format:
	--[[
		items = {
			{name = 'thing', callback = function() end}
		}
	]]--
	local wid = wibox.widget {
		widget = wibox.container.background,
		bg = bgcolor,
		id = 'bg',
		shape = helpers.rrect(6),
		{
			widget = wibox.container.margin,
			margins = beautiful.dpi(4),
			{
				layout = wibox.layout.fixed.vertical,
				spacing = beautiful.dpi(6),
				{
					layout = wibox.layout.fixed.horizontal,
					id = 'base',
					spacing = beautiful.dpi(12),
					{
						widget = wibox.widget.textbox,
						font = beautiful.fontName .. ' Medium 14',
						text = default,
						valign = 'bottom',
						id = 'selection'
					},
					w.icon('expand-more', {size = beautiful.dpi(24)})
				},
				{
					layout = wibox.layout.overflow.vertical,
					spacing = beautiful.dpi(2),
					visible = false,
					id = 'items'
				}
			}
		}
	}

	local itemLayout = wid:get_children_by_id 'items'[1]
	local selection = wid:get_children_by_id 'selection'[1]
	local function toggleDropDown(cursor)
		cursor = cursor or true
		itemLayout.visible = not itemLayout.visible
		if cursor then wid:toggleHoverCursor() end -- TODO: FIX
		wid:toggleClickableDisplay()
	end

	for _, item in ipairs(items) do
		local itemWidget = wibox.widget {
			widget = wibox.container.background,
			bg = bgcolor,
			id = 'bg',
			shape = helpers.rrect(6),
			{
				widget = wibox.container.margin,
				{
					widget = wibox.widget.textbox,
					font = beautiful.font:gsub('%d+$', '14'),
					text = item.name,
				}
			}
		}

		itemWidget.buttons = {
			awful.button({}, 1, function()
				item.callback()
				toggleDropDown(false)
				selection.text = item.name
			end)
		}

		itemLayout:add(itemWidget)
		helpers.displayClickable(itemWidget, {bg = bgcolor})
	end

	local base = wid:get_children_by_id 'base'[1]
	base.buttons = {
		awful.button({}, 1, toggleDropDown)
	}

	helpers.displayClickable(wid, {bg = bgcolor})

	return wid
end

local prettyPowerName = {
	powerSave = 'Power Saving',
	balanced = 'Balanced',
	performance = 'Performance'
}

local wid = wibox.widget {
	layout = wibox.layout.fixed.vertical,
	spacing = beautiful.dpi(6),
	{
		layout = wibox.layout.fixed.horizontal,
		--w.icon('battery', {size = beautiful.dpi(128)}),
		{
			layout = wibox.layout.fixed.vertical,
			spacing = beautiful.dpi(14),
			{
				widget = wibox.widget.textbox,
				font = beautiful.fontName .. ' Bold 32',
				id = 'percentage',
				text = '',
				valign = 'center'
			},
			{
				widget = wibox.widget.textbox,
				font = beautiful.fontName .. ' Medium 16',
				id = 'status',
				text = ''
			},
			percentageBar,
			{
				widget = wibox.widget.textbox,
				font = beautiful.font:gsub('%d+$', '18'),
				id = 'time',
				text = ''
			},
		}
	},
	{
		layout = wibox.layout.fixed.vertical,
		{
			layout = wibox.layout.align.horizontal,
			{
				widget = wibox.container.place,
				valign = 'top',
				{
					widget = wibox.widget.textbox,
					font = beautiful.fontName .. ' Bold 16',
					text = 'Power Profile'
				}
			},	
			{
				widget = wibox.container.place,
				halign = 'right',
				dropDown (prettyPowerName[battery.profile()], {
					{
						name = 'Power Saving',
						callback = function()
							battery.setProfile 'powerSave'
						end
					},
					{
						name = 'Balanced',
						callback = function()
							battery.setProfile 'balanced'
						end
					},
					{
						name = 'Performance',
						callback = function()
							battery.setProfile 'performance'
						end
					}
				}),
			},
		},
		{
			widget = wibox.widget.textbox,
			font = beautiful.fontName .. ' Bold 16',
			text = 'Battery Graph',
		},
		{
			widget = wibox.widget.textbox,
			font = beautiful.fontName .. ' Medium 14',
			text = 'Usage since last full charge',
		},
	}
}

local percentage = wid:get_children_by_id 'percentage'[1]
local status = wid:get_children_by_id 'status'[1]
local time = wid:get_children_by_id 'time'[1]

function setStatus(s)
	if s == 'Discharging' then
		status.text = 'Not Charging'
	else
		status.text = s
	end

	if s == 'Charging' then
		helpers.transitionColor {
			old = percentageBar.color,
			new = beautiful.xcolor2,
			transformer = function(col)
				percentageBar.color = col
			end,
			duration = 0.5
		}
	elseif s == 'Full' or s == 'Discharging' then
		helpers.transitionColor {
			old = percentageBar.color,
			new = beautiful.accent,
			transformer = function(col)
				percentageBar.color = col
			end,
			duration = 0.5
		}
	end
end

percentage.text = string.format('%d%%', math.floor(battery.percentage()))
percentageBar.value = math.floor(battery.percentage())
setStatus(battery.status())
if battery.status() == 'Full' then
	time.text = ''
else
	time.text = battery.time()
end

awesome.connect_signal('battery::status', setStatus)
awesome.connect_signal('battery::percentage', function(percent)
	percentage.text = string.format('%d%%', math.floor(percent))
	percentageBar.value = math.floor(battery.percentage())
	if percent < 20 then
		helpers.transitionColor {
			old = percentageBar.color,
			new = beautiful.xcolor1,
			transformer = function(col)
				percentageBar.color = col
			end,
			duration = 0.5
		}
	end
end)

awesome.connect_signal('battery::time', function(t)
	if battery.status() == 'Full' then
		time.text = ''
		return
	end

	time.text = t
end)

function M.enabled()
	return true
end

function M.display(layout)
	layout:add(wid)
end

function M.status()
	return true, 'Battery'
end

return M
