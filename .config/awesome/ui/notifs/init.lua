local beautiful = require 'beautiful'
local naughty = require 'naughty'

naughty.config.spacing = beautiful.notification_spacing
naughty.config.padding = beautiful.notification_padding
naughty.config.defaults.margin = beautiful.notification_margin
naughty.config.defaults.position = beautiful.notification_position

require 'ui.notifs.playerctl'

