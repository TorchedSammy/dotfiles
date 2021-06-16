-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, 'luarocks.loader')

themename = 'clouds'
picom = true

local awful = require 'awful'
require 'awful.autofocus'
require 'awful.hotkeys_popup.keys'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local naughty = require 'naughty'

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify {
		preset = naughty.config.presets.critical,
		title = 'Oops, there were errors during startup!',
		text = awesome.startup_errors
	}
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal('debug::error', function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify {
			preset = naughty.config.presets.critical,
			title = 'Oops, an error happened!',
			text = tostring(err)
		}
		in_error = false
	end)
end

beautiful.init('~/.config/awesome/themes/' .. themename .. '/theme.lua')

require 'conf'

awful.screen.connect_for_each_screen(function(s)
	local l = awful.layout.suit
	local layouts = { l.floating, l.tile, l.floating, l.tile, l.floating, l.floating, l.floating, l.floating, l.floating }
	awful.tag({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, s, layouts)
end)

-- {{{ Rules
-- Rules to apply to new clients (through the 'manage' signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = { },
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap+awful.placement.no_offscreen
		}
	},

	-- Floating clients.
	{ rule_any = {
		instance = {
		  'DTA',  -- Firefox addon DownThemAll.
		  'copyq',  -- Includes session name in class.
		  'pinentry',
		},
		class = {
		  'Arandr',
		  'Blueman-manager',
		  'Gpick',
		  'Kruler',
		  'MessageWin',  -- kalarm.
		  'Sxiv',
		  'Tor Browser', -- Needs a fixed window size to avoid fingerprinting by screen size.
		  'Wpa_gui',
		  'veromix',
		  'xtightvncviewer'},

		-- Note that the name property shown in xprop might be set slightly after creation of the client
		-- and the name shown there might not match defined rules here.
		name = {
		  'Event Tester',  -- xev.
		},
		role = {
		  'AlarmWindow',  -- Thunderbird's calendar.
		  'ConfigManager',  -- Thunderbird's about:config.
		  'pop-up',       -- e.g. Google Chrome's (detached) Developer Tools.
		}
	  }, properties = { floating = true }},

	-- Add titlebars to normal clients and dialogs
	{ rule_any = {type = { 'normal', 'dialog' }
	  }, properties = { titlebars_enabled = beautiful.titlebars }
	},

	-- Set Firefox to always map on the tag named '2' on screen 1.
	{ rule_any = { class = {'Google-chrome', 'discord'} },
	   properties = { maximized_vertical = true, maximized_horizontal = true } },
}
-- }}}

-- Signal function to execute when a new client appears.
client.connect_signal('manage', function(c)
	if not awesome.startup then awful.client.setslave(c) end
	if awesome.startup and not c.size_hints.user_position
	and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end
	if c.maximized then
		awful.placement.maximize(c, {
            honor_padding = true,
            honor_workarea = true,
            margins = beautiful.useless_gap * 2
        })
	end
end)

require 'ui'

if beautiful.double_borders then require 'ui.double-borders' end

client.connect_signal('focus', function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal('unfocus', function(c)
	c.border_color = beautiful.border_normal
end)

collectgarbage('setpause', 110)
collectgarbage('setstepmul', 1000)

