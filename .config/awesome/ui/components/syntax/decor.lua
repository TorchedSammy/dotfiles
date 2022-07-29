local awful = require 'awful'
local base = require 'ui.components.syntax.base'
--local beautiful = require 'beautiful'
local wibox = require 'wibox'

local function setupSidebar(c)
	if c.requests_no_titlebar or c.class == 'mpv' then
		return
	end

	awful.titlebar(c, {size = base.width * 1.5, bg = '#00000000', position = 'left'}): setup {
		layout = wibox.layout.fixed.horizontal,
		base.sideDecor {
			h = c.height
		}
	}
end

client.connect_signal('request::titlebars', function(c)
	setupSidebar(c)
end)

client.connect_signal('property::size', function(c)
	setupSidebar(c)
end)

-- dumb code to put widget below clietnt (wip)
--[[
client.connect_signal('manage', function (c)
	local under = wibox {
		width = beautiful.dpi(480),
		height = beautiful.dpi(180),
		bg = beautiful.border_color,
		shape = gears.shape.rectangle,
		ontop = false,
		visible = true
	}

	local function underSetup(c)
		if not c.fullscreen then
			awful.placement.next_to(under, {
				mode = 'geometry',
				preferred_positions = 'top',
				preferred_anchors = 'back',
				geometry = c:geometry()
			})
		end	
	end

	underSetup(c)

	client.connect_signal("property::size", underSetup)
	client.connect_signal("request::geometry", underSetup)
end)
]]--
