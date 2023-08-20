local awful = require 'awful'
local beautiful = require 'beautiful'
local base = require 'ui.extras.syntax.base'
local dpi = beautiful.dpi
local gears = require 'gears'
local helpers = require 'helpers'
local rubato = require 'libs.rubato'
local settings = require 'conf.settings'
local wibox = require 'wibox'
local w = require 'ui.widgets'
local bluetooth = require 'modules.bluetooth'
local inputbox = require 'ui.widgets.inputbox'

local deviceUniqueIdx = 0
local M = {
	title = 'Bluetooth',
	list = wibox.layout.fixed.vertical(),
	deviceList = {},
	deviceOccurrences = {},
}

-- @return boolean state of the setting (on or off)
function M.toggle()
	return bluetooth.toggle()
end

function M.enabled()
	return bluetooth.enabled
end

local function createDeviceWidget(device)
	local connectBtn = w.button('bluetooth', {text = 'Connect', bg = beautiful.accent, shiftFactor = 25})
	connectBtn.buttons = {
		awful.button({}, 1, function()
			bluetooth.connect(device)
		end)
	}

	local spacing = beautiful.dpi(6)
	local bgcolor = beautiful.bg_sec
	local wid = wibox.widget {
		layout = wibox.container.place,
		halign = 'left',
		id = device,
		{
			widget = wibox.container.background,
			shape = helpers.rrect(base.radius),
			bg = connected and beautiful.accent or bgcolor,
			id = 'bg',
			{
				widget = wibox.container.margin,
				margins = beautiful.dpi(6),
				{			
					layout = wibox.layout.fixed.vertical,
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = spacing,
						w.icon('bluetooth', {size = beautiful.dpi(32)}),
						{
							widget = wibox.widget.textbox,
							markup = helpers.colorize_text(device.Name, beautiful.fg_normal),
							font = beautiful.font:gsub('%d+$', '16')
						}
					},
					{
						widget = wibox.container.place,
						halign = 'right',
						visible = false,
						connectBtn
					}
				}
			}
		}	
	}

	helpers.displayClickable(wid, {color = connected and beautiful.accent or bgcolor})
	wid.buttons = {
		awful.button({}, 1, function()
			wid:get_children_by_id 'bluetooth-control'[1].visible = true
			wid:emit_signal 'hover::disconnect'
			wid:emit_signal 'dc::disconnect'
		end)
	}

	return wid
end

function reset()
	M.deviceOccurrences = {}
	M.deviceList = {}
	M.list:reset()
end

function addDevice(device)
	if not M.deviceOccurrences[device.Name] then
		M.list:add(createDeviceWidget(device))

		table.insert(M.deviceList, device.Name)
		M.deviceOccurrences[device.Name] = 0
	end
	M.deviceOccurrences[device.Name] = M.deviceOccurrences[device.Name] + 1
end

function refresh()
	reset()
	bluetooth.getDevices(addDevice)
end

--[[
awesome.connect_signal('bluetooth::ap-added', addDevice)
awesome.connect_signal('bluetooth::ap-removed', function(ap)
	M.deviceOccurrences = {}
	M.deviceList = {}
	M.list:reset()
	bluetooth.getDevices(addDevice)
end)
]]--

refresh()

function M.update(layout)
	layout:add(M.list)
end

function M.display(layout)
	M.update(layout)

	return M.list
end

function M.status()
	return bluetooth.enabled, ''
end

return M
