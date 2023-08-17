local awful = require 'awful'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local gears = require 'gears'
local w = require 'ui.widgets'
local helpers = require 'helpers'
local battery = require 'modules.battery'
local M = {
	title = 'Battery',
}

local bgcolor = beautiful.bg_sec

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
						font = beautiful.font:gsub('%d+$', '14'),
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
		w.icon('battery', {size = beautiful.dpi(128)}),
		{
			layout = wibox.layout.fixed.vertical,
			{
				widget = wibox.widget.textbox,
				font = beautiful.font:gsub('%d+$', '24'),
				id = 'status',
				text = ''
			},
			{
				widget = wibox.widget.textbox,
				font = beautiful.font:gsub('%d+$', '22'),
				id = 'percentage',
				text = ''
			},
			{
				widget = wibox.widget.textbox,
				font = beautiful.font:gsub('%d+$', '18'),
				id = 'time',
				text = ''
			},
		}
	},
	{
		layout = wibox.layout.align.horizontal,
		{
			widget = wibox.container.place,
			valign = 'top',
			{
				widget = wibox.widget.textbox,
				font = beautiful.font:gsub('%d+$', '18'),
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
			})
		}
	}
}

local percentage = wid:get_children_by_id 'percentage'[1]
local status = wid:get_children_by_id 'status'[1]
local time = wid:get_children_by_id 'time'[1]

percentage.text = string.format('%d%%', math.floor(battery.percentage()))
status.text = battery.status()
if battery.status() == 'Full' then
	time.text = ''
else
	time.text = battery.time()
end

awesome.connect_signal('battery::status', function(s)
	status.text = s
end)
awesome.connect_signal('battery::percentage', function(percent)
	percentage.text = string.format('%d%%', math.floor(percent))
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
	return true, ''
end

return M
