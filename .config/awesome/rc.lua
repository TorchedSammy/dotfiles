-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, 'luarocks.loader')

local awful = require 'awful'
local beautiful = require 'beautiful'
local compositor = require 'modules.compositor'
local gears = require 'gears'
local helpers = require 'helpers'
local ruled = require 'ruled'
local naughty = require 'naughty'
local wibox = require 'wibox'
local settings = require 'conf.settings'
local scheduler = require 'modules.scheduler'
local extrautils = require 'libs.extrautils'()

require 'libs.succulent'
require 'awful.autofocus'
require 'awful.hotkeys_popup.keys'
require 'signals'

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

require 'conf'

screen.connect_signal('property::geometry', helpers.set_wallpaper)
awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	local margin = beautiful.useless_gap

	local mul = beautiful.dpi(1)
	s.padding = {
		top = margin * mul,
		left = margin * mul, right = margin * mul,
		bottom = margin * mul
	}
	local l = awful.layout.suit
	local layouts = { l.floating, l.tile, l.floating, l.tile, l.floating, l.floating, l.floating, l.floating, l.floating }
	local taglist = {}
	for i = 1, beautiful.taglist_number do
		taglist[i] = tostring(i)
	end
	awful.tag(taglist, s, layouts)
end)

local placer = awful.placement.no_overlap+awful.placement.no_offscreen

ruled.client.connect_signal("request::rules", function()
	-- @DOC_GLOBAL_RULE@
	-- All clients will match this rule.
	ruled.client.append_rule {
		id         = "global",
		rule       = { },
		properties = {
			focus     = awful.client.focus.filter,
			raise     = true,
			screen    = awful.screen.preferred,
			placement = function(c) placer(c, {honor_workarea = true, honor_padding = true}) end,
			--placement = awful.placement.no_overlap+awful.placement.no_offscreen,
			keys = clientkeys,
			buttons = clientbuttons,
		}
	}

	-- @DOC_FLOATING_RULE@
	-- Floating clients.
	ruled.client.append_rule {
		id       = "floating",
		rule_any = {
			instance = { "copyq", "pinentry" },
			class    = {
				"Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
				"Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
			},
			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name    = {
				"Event Tester",  -- xev.
			},
			role    = {
				"AlarmWindow",    -- Thunderbird's calendar.
				"ConfigManager",  -- Thunderbird's about:config.
				"pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
			}
		},
		properties = { floating = true }
	}

	-- @DOC_DIALOG_RULE@
	-- Add titlebars to normal clients and dialogs
	ruled.client.append_rule {
		-- @DOC_CSD_TITLEBARS@
		id         = "titlebars",
		rule_any   = { type = { "normal", "dialog" } },
		properties = { titlebars_enabled = true      }
	}

	ruled.client.append_rule {
		id       = "notitlebar",
		rule_any = {
			class    = {
			   "osu!.exe"
			},
		},
		properties = { titlebars_enabled = false }
	}

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- ruled.client.append_rule {
	--     rule       = { class = "Firefox"     },
	--     properties = { screen = 1, tag = "2" }
	-- }
end)


require 'ui'

-- Signal function to execute when a new client appears.
client.connect_signal('manage', function(c)
	if not awesome.startup then awful.client.setslave(c) end

	if c.maximized then
		helpers.winmaxer(c)
	end

	if not c.maximized and not c.fullscreen then
		awful.placement.centered(c, {parent = c.transient_for or c.screen or awful.screen.focused()})
	end

	if c.sticky then
		c.floating = true
	end

--[[
	if c.floating then
		if c.transient_for ~= nil then
			awful.placement.centered(c, {parent = c.transient_for})
		else
			awful.placement.centered(c, {parent = awful.screen.focused()})
		end
	end
]]--

	local cairo = require("lgi").cairo
	local default_icon = extrautils.apps.lookup_icon('application-x-executable')
	if c and c.valid and not c.icon then
		local s = gears.surface(default_icon)
		local img = cairo.ImageSurface.create(cairo.Format.ARGB32, s:get_width(), s:get_height())
		local cr = cairo.Context(img)
		cr:set_source_surface(s, 0, 0)
		cr:paint()
		c.icon = img._native
	end
end)

if beautiful.double_borders then require 'ui.extras.double-borders' end

require 'initialize'

client.connect_signal('focus', function(c)
	helpers.transitionColor {
		old = beautiful.border_normal,
		new = beautiful.border_focus,
		transformer = function(col)
			local valid = pcall(function() return c.valid end) and c.valid
			if not valid then return end

			c.border_color = col
		end,
		duration = 0.2
	}
	if c.pid then
		scheduler.setForeground(c.pid)
	end
end)

client.connect_signal('unfocus', function(c)
	helpers.transitionColor {
		old = beautiful.border_focus,
		new = beautiful.border_normal,
		transformer = function(col)
			local valid = pcall(function() return c.valid end) and c.valid
			if not valid then return end

			c.border_color = col
		end,
		duration = 0.4
	}
end)

collectgarbage('setpause', 110)
collectgarbage('setstepmul', 1000)

--require 'ui.setup'.start()
require 'ui.extras.compositor'

