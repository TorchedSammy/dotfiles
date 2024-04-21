local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty'
local settings = require 'conf.settings'
local sfx = require 'modules.sfx'
local lockscreen = require 'ui.lockscreen'

naughty.config.spacing = beautiful.notification_spacing
naughty.config.padding = beautiful.notification_padding
naughty.config.defaults.margin = beautiful.notification_margin
naughty.config.defaults.position = beautiful.notification_position
naughty.config.defaults.border_width = beautiful.notification_border_width

naughty.connect_signal('added', function(notif)
	if notif.category == 'system.playerctl' or lockscreen.locked() then return end

	local categorySound = {
		['device.added'] = 'deviceAdded',
		['device.removed'] = 'deviceRemoved',
	}

	if notif.category and categorySound[notif.category] then
		sfx.play(categorySound[notif.category])
	else
		sfx.notify()
	end
end)

if package.searchpath('ui.notifs.' .. settings.theme, package.path) then
	require('ui.notifs.' .. settings.theme)
	--[[
	local ok, err = pcall(require, 'ui.notifs.' .. settings.theme)
	if not ok then
		naughty.notify {
			preset = naughty.config.presets.critical,
			title = 'Error running theme-specific notification display!',
			text = err
		}
	end
	]]--
end

require 'ui.notifs.playerctl'
require 'ui.notifs.battery'
