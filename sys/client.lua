local awful = require 'awful'
local ruled = require 'ruled'

ruled.client.connect_signal('request::rules', function()
	ruled.client.append_rule {
		id = 'global',
		rule = {},
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap+awful.placement.no_offscreen,
		}
	}

	ruled.client.append_rule {
		id = 'titlebar',
		rule_any = {
			type = {
				'normal',
				'dialog'
			}
		},
		properties = {
			titlebars_enabled = true
		}
	}
end)

local function restrictHeight(c)
	if c:geometry().height > c.screen.workarea.height and not c.fullscreen then
		c:geometry {
			height = c.screen.workarea.height
		}
	end
end

client.connect_signal('manage', function(c)
	restrictHeight(c)
	if not awesome.startup then awful.client.setslave(c) end
end)

client.connect_signal('request::geometry', function(c)
	restrictHeight(c)
	awful.placement.no_offscreen(c)
end)
