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
local util = require 'ui.widgets.quickSettings.util'

local M = {
	title = 'Wi-fi',
	list = wibox.layout.fixed.vertical(),
	active = nil
}

-- @return boolean state of the setting (on or off)
function M.toggle()
	wifi.toggle()
end

function M.enabled()
	return wifi.enabled
end

local function createAPWidget(ssid, ap)
	local secure = true --wifi.getAPSecurity(ap) ~= ''
	local connected = wifi.activeSSID == ssid
	local passwordVisible = false

	local password = inputbox {
		password_mode = true,
		mouse_focus = true,
		fg = beautiful.accent,
		text_hint = 'Enter password...',
		font = beautiful.font:gsub('%d+$', '10')
	}
	helpers.hoverCursor(password.widget, 'xterm')

	local connectBtn = w.button('wifi', {
		text = 'Connect',
		bg = bgcolor, --beautiful.accent,
		shiftFactor = 25,
		onClick = function()
			wifi.connect(ap, password:get_text())
		end
	})

	local spacing = beautiful.dpi(10)
	local bgcolor = beautiful.bg_sec
	--[[
	local wid = wibox.widget {
		widget = wibox.container.constraint,
		strategy = 'exact',
		width = beautiful.dpi(420),
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
							layout = wibox.layout.stack,
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
							},
							{
								widget = wibox.container.place,
								halign = 'right',
								w.button('visibility-off', {
									bg = bgcolor,
									onClick = function(self)
										if passwordVisible then
											self.icon = 'visibility-off'
										else
											self.icon = 'visibility'
										end
										passwordVisible = not passwordVisible
									end
								})
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
	]]--

	local passwordEntry = wibox.widget {
		layout = wibox.layout.align.horizontal,
		{
			widget = wibox.container.constraint,
			strategy = 'max',
			width = beautiful.dpi(420 - (20 * 2)),
			password.widget,
		},
		{
			widget = wibox.container.place,
			halign = 'right',
			w.button('visibility-off', {
				bg = bgcolor,
				onClick = function(self)
					if passwordVisible then
						self.icon = 'visibility-off'
					else
						self.icon = 'visibility'
					end
					passwordVisible = not passwordVisible
				end
			})
		}
	}

	local wid = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = spacing,
			w.icon(secure and 'wifi-ap-locked' or 'wifi-ap', {
				size = beautiful.dpi(32),
				--color = beautiful.xcolor14
			}),
			{
				widget = wibox.container.place,
				valign = 'center',
				{
					layout = wibox.layout.fixed.vertical,
					{
						widget = wibox.widget.textbox,
						markup = helpers.colorize_text(ssid, connected and beautiful.accent or beautiful.fg_normal),
						font = string.format('%s %s 12', beautiful.fontName, connected and 'Bold' or 'Medium'),
					},
					connected and {
						widget = wibox.widget.textbox,
						text = 'Connected',
					} or nil,
				}
			}
		},
		not connected and passwordEntry or nil
	}

	helpers.displayClickable(wid, {color = connected and beautiful.accent or bgcolor})
	--[[wid.buttons = {
		awful.button({}, 1, function()
			password:unfocus()
			wid:get_children_by_id 'wifi-control'[1].visible = true
			wid:emit_signal 'hover::disconnect'
			wid:emit_signal 'dc::disconnect'
		end)
	}]]--

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

--[[
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

]]--
function M.fetch(layout)
	M.list:reset()

	local aps = wifi.getAccessPoints()
	for ssid, ap in pairs(aps) do
		local apWidget = createAPWidget(ssid, ap)
		if wifi.activeSSID == ssid then
			M.active = apWidget
		else
			M.list:add(apWidget)
		end
	end
end

function M.display(layout)
	layout:add(wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = beautiful.dpi(20) * 2,
		spacing_widget = {
			widget = wibox.widget.separator,
			thickness = beautiful.dpi(4),
			color = beautiful.bg_sec
		},
		M.active,
		M.list
	})
end

function M.status()
	return M.enabled(), M.enabled() and (wifi.activeSSID and wifi.activeSSID or 'Not connected') or 'Wi-fi'
end

awesome.connect_signal('wifi::toggle', function(state)
	util.emitSignal('wifi', 'toggle', state)

	local enabled, textStatus = M.status()
	util.emitSignal('wifi', 'status', textStatus)
end)

awesome.connect_signal('wifi::disconnected', function()
	local enabled, textStatus = M.status()
	util.emitSignal('wifi', 'status', textStatus)
	M.active.visible = false
	M.fetch()
end)

awesome.connect_signal('wifi::activeAP', function()
	local enabled, textStatus = M.status()
	util.emitSignal('wifi', 'status', textStatus)
	M.fetch()
end)

return M
