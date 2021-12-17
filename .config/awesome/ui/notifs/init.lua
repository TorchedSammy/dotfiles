local beautiful = require 'beautiful'
local naughty = require 'naughty'

naughty.config.spacing = beautiful.notification_spacing
naughty.config.padding = beautiful.notification_padding
naughty.config.defaults.margin = beautiful.notification_margin
naughty.config.defaults.position = beautiful.notification_position
naughty.config.defaults.border_width = beautiful.notification_border_width

require 'ui.notifs.playerctl'

