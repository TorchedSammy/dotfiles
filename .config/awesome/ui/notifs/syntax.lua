local beautiful = require 'beautiful'
local base = require 'ui.components.syntax.base'
local gears = require 'gears'
local naughty = require 'naughty'
local wibox = require 'wibox'

naughty.connect_signal('request::display', function(notification)
	notification.timeout = 3
	notification.resident = false
	if notification.icon == nil then
		naughty.layout.box {
			notification = notification,
			border_width = 0,
			widget_template = {
				{
					layout = wibox.layout.fixed.horizontal,
					{
						{
							{
								{
									layout = wibox.container.place,
									valign = 'center',
									halign = 'left',
									{
										{
											{
											widget = wibox.widget.textbox,
											text = notification.title ~= '' and notification.title or '<No Title>',
											font = beautiful.font_bold:gsub('%d+$', '16')
										},
										{
											widget = wibox.widget.textbox,
											text = notification.text ~= '' and notification.text or '<No Text>',
											font = beautiful.font:gsub('%d+$', '16')
										},
											spacing = beautiful.dpi(6),
											layout = wibox.layout.fixed.vertical,
										},
										spacing = beautiful.dpi(8),
										layout = wibox.layout.fixed.horizontal,
									}
								},
								margins = beautiful.notification_margin,
								widget  = wibox.container.margin,
							},
							strategy = 'exact',
							width = beautiful.notification_width or beautiful.notification_max_width or beautiful.dpi(500),
							height = beautiful.notification_height,
							widget = wibox.container.constraint,
						},
						shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, false, true, base.rad) end,
						widget = wibox.container.background,
						bg = beautiful.notification_bg
					},
					base.sideDecor {
						h = beautiful.notification_height,
						bg = beautiful.notification_bg,
						position = 'right',
						noRounder = true
					},
				},
				bg = '#00000000',
				widget = wibox.container.background,
			}
		}
	else
		naughty.layout.box {
			notification = notification,
			border_width = 0,
			widget_template = {
				{
					layout = wibox.layout.fixed.horizontal,
					{
						{
							{
								{
									layout = wibox.container.place,
									valign = 'center',
									halign = 'left',
									{
										{
											widget = naughty.widget.icon,
											valign = 'center'
										},
										{
											{
											widget = wibox.widget.textbox,
											text = notification.title ~= '' and notification.title or '<No Title>',
											font = beautiful.font_bold:gsub('%d+$', '16')
										},
										{
											widget = wibox.widget.textbox,
											text = notification.text ~= '' and notification.text or '<No Text>',
											font = beautiful.font:gsub('%d+$', '16')
										},
											spacing = beautiful.dpi(6),
											layout = wibox.layout.fixed.vertical,
										},
										spacing = beautiful.dpi(8),
										layout = wibox.layout.fixed.horizontal,
									}
								},
								margins = beautiful.notification_margin,
								widget  = wibox.container.margin,
							},
							strategy = 'exact',
							width = beautiful.notification_width or beautiful.notification_max_width or beautiful.dpi(500),
							height = beautiful.notification_height,
							widget = wibox.container.constraint,
						},
						shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, false, true, base.rad) end,
						widget = wibox.container.background,
						bg = beautiful.notification_bg
					},
					base.sideDecor {
						h = beautiful.notification_height,
						bg = beautiful.notification_bg,
						position = 'right',
						noRounder = true
					},
				},
				bg = '#00000000',
				widget = wibox.container.background,
			}
		}
	end
end)

--[[
	
							{
								widget_template = {
										{
											{
												{
													id            = 'icon_role',
													forced_height = 16,
													forced_width  = 16,
													widget        = wibox.widget.imagebox
												},
												{
													id     = 'text_role',
													widget = wibox.widget.textbox
												},
												spacing = 5,
												layout = wibox.layout.fixed.horizontal
											},
											widget             = wibox.container.background,
										},
										margins = 4,
										widget  = wibox.container.margin,
									},
									widget = naughty.list.actions,
								},
]]
