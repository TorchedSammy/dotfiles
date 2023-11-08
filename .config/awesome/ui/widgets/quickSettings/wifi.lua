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
local wifi = require 'modules.wifi'
local inputbox = require 'ui.widgets.inputbox'

local ssidUniqueIdx = 0
local M = {
	title = 'Wi-fi',
	list = wibox.layout.fixed.vertical(),
	ssidList = {},
	ssidOccurrences = {},
}

-- @return boolean state of the setting (on or off)
function M.toggle()
	return wifi.toggle()
end

function M.enabled()
	return wifi.enabled
end

local function createAPWidget(ap)
	local secure = wifi.getAPSecurity(ap) ~= ''
	local ssid = wifi.getSSID(ap)
	local connected = wifi.isActiveAP(ap)

	local password = inputbox {
		password_mode = true,
		mouse_focus = true,
		fg = beautiful.accent,
		text_hint = 'Enter password...',
		font = beautiful.font:gsub('%d+$', '10')
	}
	helpers.hoverCursor(password.widget, 'xterm')

	local connectBtn = w.button('wifi', {text = 'Connect', bg = beautiful.accent, shiftFactor = 25})
	connectBtn.buttons = {
		awful.button({}, 1, function()
			wifi.connect(ap, password:get_text())
		end)
	}

	local spacing = beautiful.dpi(6)
	local bgcolor = beautiful.bg_sec
	local wid = wibox.widget {
		layout = wibox.container.place,
		halign = 'left',
		id = ssid,
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
						w.icon(secure and 'wifi-ap-locked' or 'wifi-ap', {size = beautiful.dpi(32)}),
						{
							widget = wibox.widget.textbox,
							markup = helpers.colorize_text(ssid, beautiful.fg_normal),
							font = beautiful.font:gsub('%d+$', '16')
						}
					},
					{
						layout = wibox.layout.grid,
						id = 'wifi-control',
						spacing = spacing,
						visible = false,
						secure and {
							layout = wibox.layout.align.horizontal,
							{
								widget = wibox.widget.textbox,
								markup = helpers.colorize_text('Password', beautiful.fg_normal),
								font = beautiful.font:gsub('%d+$', '14')
							},
							{
								widget = wibox.container.margin,
								left = spacing,
								{
									widget = wibox.container.background,
									bg = helpers.shiftColor(bgcolor, 6),
									shape = helpers.rrect(base.radius),
									{
										widget = wibox.container.margin,
										margins = beautiful.dpi(2),
										password.widget
									}
								}
							}
						} or nil,
						{
							layout = wibox.layout.align.horizontal,
							{	
								layout = wibox.layout.fixed.horizontal,
								spacing = spacing,
								w.switch {color = beautiful.accent},
								{
									widget = wibox.widget.textbox,
									markup = helpers.colorize_text('Auto connect', beautiful.fg_normal),
									font = beautiful.font:gsub('%d+$', '14')
								},
							},
							{
								widget = wibox.container.place,
							},
							connectBtn
						}
					}
				}
			}
		}	
	}

	helpers.displayClickable(wid, {color = connected and beautiful.accent or bgcolor})
	wid.buttons = {
		awful.button({}, 1, function()
			password:unfocus()
			wid:get_children_by_id 'wifi-control'[1].visible = true
			wid:emit_signal 'hover::disconnect'
			wid:emit_signal 'dc::disconnect'
		end)
	}

	return wid
end
function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function addAP(ap)
	local ssid = wifi.getSSID(ap)
	if not ssid then return end

	if not M.ssidOccurrences[ssid] then
		M.list:add(createAPWidget(ap))

		table.insert(M.ssidList, ssid)
		M.ssidOccurrences[ssid] = 0
	end
	M.ssidOccurrences[ssid] = M.ssidOccurrences[ssid] + 1
end

awesome.connect_signal('wifi::ap-added', addAP)
awesome.connect_signal('wifi::ap-removed', function()
	M.ssidOccurrences = {}
	M.ssidList = {}
	M.list:reset()
	wifi.getAPs(addAP)
end)

wifi.getAPs(addAP)

function M.update(layout)
	wifi.getAPs(function() end)
	layout:add(M.list)
end

function M.display(layout)
	M.update(layout)

	return M.list
end

function M.status()
	return true, wifi.activeAPSSID and wifi.activeAPSSID or 'Not connected'
end

return M
