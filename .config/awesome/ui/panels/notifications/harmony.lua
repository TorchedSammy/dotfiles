local beautiful = require 'beautiful'
local gears = require 'gears'
local harmony = require 'ui.components.harmony'
local helpers = require 'helpers'
local widgets = require 'ui.widgets'
local wibox = require 'wibox'
local naughty = require 'naughty'
local notiflist = require 'ui.widgets.notificationlist'
local notificationW = require 'ui.widgets.notification'

local panelTitle, panelTitleHeight = harmony.titlebar('Notifications', {
	after = wibox.widget {
		layout = wibox.container.place,
		halign = 'right',
		content_fill_horizontal = false,
		widgets.button {
			icon = 'clear-all',
			size = beautiful.dpi(28),
			onClick = naughty.destroy_all_notifications
		}
	}
})
local notificationsPanel = helpers.aaWibox  {
	height = beautiful.dpi(250) + panelTitleHeight,
	width = beautiful.dpi(460),
	bg = 'bg_popup',
	rrectRadius = beautiful.radius,
	shape = gears.shape.rectangle,
	ontop = true,
	visible = false
}
naughty.notify {
	title = 'ssf',
	text = 'Image uploaded!',
	image = '/tmp/screenshot.png'
}

local panelLayout = wibox.layout.overflow.vertical()
panelLayout.step = beautiful.dpi(100)
panelLayout.scrollbar_widget = {
	widget = wibox.widget.separator,
	shape = gears.shape.rounded_bar,
	color = beautiful.accent
}
panelLayout.scrollbar_width = beautiful.dpi(10)
panelLayout.spacing = beautiful.dpi(8)

notificationsPanel:setup {
	layout = wibox.layout.fixed.vertical,
	panelTitle,
	{
		layout = wibox.container.margin,
		margins = beautiful.dpi(8),
		{
			widget = notiflist,
			--filter = function(n) return naughty.list.notifications.filter.most_recent(n, 3) end,
			base_layout = wibox.widget {
				layout = panelLayout
			},
			widget_template = {
				widget = wibox.container.background,
				bg = beautiful.containerHigh,
				shape = helpers.rrect(beautiful.radius / 2),
				{
					layout = wibox.container.margin,
					margins = beautiful.dpi(8),
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.dpi(16),
						-- todo: notification category icon
						{
							-- large image
							layout = wibox.container.place,
							notificationW.image
						},
						{
							layout = wibox.layout.fixed.vertical,
							spacing = beautiful.dpi(8),
							{
								layout = wibox.layout.fixed.horizontal,
								-- icon and title
								spacing = beautiful.dpi(4),
								{
									layout = wibox.container.constraint,
									width = beautiful.dpi(24),
									height = beautiful.dpi(24),
									{
										widget = wibox.container.place,
										valign = 'center',
										notificationW.icon,
									}
								},
								naughty.widget.title
							},
							naughty.widget.message
						}
					}
				}
			}
		}
	}
}

helpers.slidePlacement(notificationsPanel, {
	placement = 'bottom_right',
	heights = {
		hide = notificationsPanel.height,
		reveal = (beautiful.useless_gap * beautiful.dpi(2)) * -1,
	},
	invert = true
})

return notificationsPanel
