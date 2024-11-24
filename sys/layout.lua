local awful = require 'awful'
local beautiful = require 'beautiful'

tag.connect_signal('request::default_layouts', function()
    awful.layout.append_default_layouts({
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.top,
        awful.layout.suit.fair,
        awful.layout.suit.fair.horizontal,
        awful.layout.suit.spiral,
        awful.layout.suit.spiral.dwindle,
        awful.layout.suit.max,
        awful.layout.suit.max.fullscreen,
        awful.layout.suit.magnifier,
        awful.layout.suit.corner.nw,
    })
end)

awful.screen.connect_for_each_screen(function(s)
	awful.tag({ '1', '2', '3', '4', '5', '6', '7', '8', '9' }, s, awful.layout.layouts[1])
	s.padding = beautiful.useless_gap
end)
