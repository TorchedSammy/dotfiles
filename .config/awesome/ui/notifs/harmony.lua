local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local naughty = require 'naughty'
local w = require 'ui.widgets'
local helpers = require 'helpers'

local categoryMappings = {
	['drive-removable-media'] = 'usb',
	['system.warning'] = 'warning'
}

local skip = {
	['device.added'] = true,
	['device.removed'] = true,
}

local function categoryToIcon(cat)
	local mapping = categoryMappings[cat]
	return mapping or cat
end

naughty.connect_signal('request::display', function(notification)
	if skip[notification.category] == true then return end

	notification.timeout = 5

	-- todo: transform category to icons
	-- i dont want *my* svg icons to match to 
	-- "network.connected" so use a table to map to names in the future
	-- this is used in the harmony codebase and actually conforms to the svg names.
	local category = categoryToIcon(notification.category)
	local notifImage
	if notification.app_icon then
		if notification.app_icon:match 'file://' or notification.app_icon:match '^/' then
			notifImage = notification.app_icon:gsub('file://', '')
		else
			category = categoryToIcon(notification.app_icon)
		end
	end
	if category and not gears.filesystem.file_readable(beautiful.config_path .. '/images/icons/' .. category .. '.svg') then
		naughty.notification {
			title = 'Missing Icon Mapping',
			text = string.format('Category %s does not have a mapping for notifications.', category),
			category = 'warning'
		}
	end
	
	local icoWidget = w.icon(category or 'notification', {
		size = beautiful.dpi(32),
		color = beautiful.xcolor14
	})
	local spacing = beautiful.dpi(16)

	local notifActions = wibox.layout.fixed.horizontal()
	notifActions.spacing = beautiful.dpi(8)
	for _, action in ipairs(notification.actions) do
		local btn = w.button('', {
			text = action.name,
			bg = beautiful.xcolor10,
			font = beautiful.fontName .. ' Medium 12',
			shiftFactor = -25,
			onClick = function()
				action:invoke(notification)
			end,
			margin = beautiful.dpi(4),
			height = beautiful.dpi(28)
		})

		notifActions:add(btn)
	end

	naughty.layout.box {
		notification = notification,
		border_width = beautiful.notification_border_width,
		bg = '#00000000',
		shape = helpers.rrect(beautiful.radius / 1.2),
		widget_template = {
			widget = wibox.container.background,
			bg = beautiful.notification_bg,
			shape = helpers.rrect(beautiful.radius),
			{
				widget = wibox.container.constraint,
				--strategy = 'exact',
				--width = beautiful.notification_width,
				--height = beautiful.notification_height,
				{
					layout = wibox.layout.fixed.horizontal,
					{
						widget = wibox.container.constraint,
						strategy = 'exact',
						width = beautiful.dpi(85),
						height = beautiful.notification_height,
						{
							widget = wibox.container.background,
							bg = beautiful.xcolor9,
							icoWidget
						}
					},
					{
						widget = wibox.container.margin,
						margins = spacing,
						{
							layout = wibox.container.place,
							{
								layout = wibox.layout.fixed.horizontal,
								spacing = beautiful.dpi(16),
								notifImage and {
									widget = wibox.container.place,
									{
										widget = wibox.container.constraint,
										strategy = 'exact',
										width = beautiful.notification_width / 5,
										{
											widget = wibox.widget.imagebox,
											clip_shape = helpers.rrect(beautiful.radius / 2),
											image = notifImage
										}
									}
								} or nil,
								{
									layout = wibox.layout.fixed.vertical,
									spacing = beautiful.dpi(8),
									{
										layout = wibox.layout.fixed.horizontal,
										spacing = beautiful.dpi(4),
										notification.image and {
											widget = wibox.container.place,
											{
												widget = wibox.container.constraint,
												strategy = 'exact',
												width = beautiful.dpi(24),
												--height = beautiful.notification_height,
												--[[{
													widget = naughty.widget.icon,
													clip_shape = gears.shape.circle
												}]]--
												{
													widget = wibox.widget.imagebox,
													clip_shape = gears.shape.circle,
													image = notification.image
												}
												--notification.clients[1] and awful.titlebar.widget.iconwidget(notification.clients[1]) or nil,
											}
										} or nil,
										{
											widget = wibox.widget.textbox,
											markup = notification.title,
											font = beautiful.fontName .. ' Bold 14',
										},
									},
									{
										widget = naughty.widget.message,
										font = beautiful.fontName .. ' Regular 14',
									},
									notifActions
								}
							}
						}
					}
				}
			}
		}
	}
end
)
