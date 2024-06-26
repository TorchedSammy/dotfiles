local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty'
local hotkeys_popup = require 'awful.hotkeys_popup'
local switcher = require 'libs.awesome-switcher'
local widgets = require 'ui.widgets'
local helpers = require 'helpers'
local sfx = require 'modules.sfx'

-- {{{ Key bindings
globalkeys = gears.table.join(
awful.key({modkey, shift}, '/', hotkeys_popup.show_help, {
	description = 'Show all hotkeys',
	group = 'awesome'
}),
--[[
awful.key({modkey}, 'Left', awful.tag.viewprev, {
	description = 'Go to previous tag',
	group = 'tag'
}),
awful.key({modkey}, 'Right', awful.tag.viewnext, {
	description = 'Go to next tag',
	group = 'tag'
}),
]]--
awful.key({modkey}, 'Escape', awful.tag.history.restore, {
	description = 'Go to the last tag visited',
	group = 'tag'
}),

awful.key({}, 'XF86MonBrightnessDown', function()
	awful.spawn.easy_async('light -U 5', function() end)
end, {
	description = 'Decrease brightness',
	group = 'screen'
}),
awful.key({}, 'XF86MonBrightnessUp', function()
	awful.spawn.easy_async('light -A 5', function() end)
end, {
	description = 'Increase brightness',
	group = 'screen'
}),
awful.key({}, 'XF86AudioMute', function()
	sfx.muteVolume()
end, {
	description = 'Mute volume',
	group = 'audio'
}),
awful.key({}, 'XF86AudioLowerVolume', function()
	sfx.volumeDown()
end, {
	description = 'Decrease volume',
	group = 'audio'
}),
awful.key({}, 'XF86AudioRaiseVolume', function()
	sfx.volumeUp()
end, {
	description = 'Increase volume',
	group = 'audio'
}),

awful.key({modkey}, 'j',
	function()
		awful.client.focus.byidx(-1)
	end, {
		description = 'Focus next client by index',
		group = 'client'
	}
),
awful.key({modkey}, 'k',
	function()
		awful.client.focus.byidx(1)
	end, {
		description = 'Focus previous client by index',
		group = 'client'
	}
),
awful.key({modkey}, 'w',
	function()
		mainmenu:show()
	end, {
		description = 'Show main menu',
		group = 'awesome'
	}
),
awful.key({control}, 'Print',
	function()
		awful.spawn.with_shell '~/bin/ss'
	end, {
		description = 'Take a regional screenshot',
		group = 'awesome'
	}
),
awful.key({control, altkey}, 'Print',
	function()
		awful.spawn.with_shell '~/bin/ss screen'
	end, {
		description = 'Take a screenshot of all screens',
		group = 'awesome'
	}
),
awful.key({}, 'Print',
	function()
		awful.spawn.with_shell '~/bin/ss window'
	end, {
		description = 'Take a screenshot of the current window',
		group = 'awesome'
	}
),
awful.key({modkey}, 'd',
	function()
		awful.spawn.with_shell 'rsync -ah --inplace --delete --info=progress2 ~/Files/Dotfiles/.config/awesome/ ~/.config/awesome/'
		naughty.notify {
			title = 'System',
			text = 'New configuration copied.',
			category = 'settings'
		}
	end, {
		description = 'Update awesome config from dotfiles folder',
		group = 'awesome'
	}
),

awful.key({modkey, shift}, 'Left', function()
	--awful.client.swap.bydirection 'left'
	awful.layout.set(awful.layout.suit.tile.right)
end, {
	description = 'Move master to the left',
	group = 'client'
}),
awful.key({modkey, shift}, 'Right', function()
	--awful.client.swap.bydirection 'right'
	awful.layout.set(awful.layout.suit.tile.left)
end, {
	description = 'Move master to the right',
	group = 'client'
}),
awful.key({modkey}, 'Left', function()
	--awful.client.swap.bydirection 'left'
	awful.client.swap.bydirection 'left'
end, {
	description = 'Move client to the left',
	group = 'client'
}),
awful.key({modkey}, 'Right', function()
	--awful.client.swap.bydirection 'right'
	awful.client.swap.bydirection 'right'
end, {
	description = 'Move client to the right',
	group = 'client'
}),
awful.key({modkey}, 'Up', function()
	--awful.client.swap.bydirection 'left'
	awful.client.swap.bydirection 'up'
end, {
	description = 'Move client up',
	group = 'client'
}),
awful.key({modkey}, 'Down', function()
	--awful.client.swap.bydirection 'right'
	awful.client.swap.bydirection 'down'
end, {
	description = 'Move client down',
	group = 'client'
}),
-- Layout manipulation
awful.key({modkey, shift}, 'j',
	function()
		awful.client.swap.byidx(1)
	end, {
		description = 'Swap position with next client by index',
		group = 'client'
	}
),
awful.key({modkey, shift}, 'k',
	function()
		awful.client.swap.byidx(-1)
	end, {
		description = 'swap with previous client by index',
		group = 'client'
	}
),
awful.key({modkey, control}, 'j',
	function()
		awful.screen.focus_relative(1)
	end, {
		description = 'focus the next screen',
		group = 'screen'
	}
),
awful.key({modkey, control}, 'k',
	function()
		awful.screen.focus_relative(-1)
	end, {
		description = 'focus the previous screen',
		group = 'screen'
	}
),
awful.key({modkey}, 'u', awful.client.urgent.jumpto, {
	description = 'jump to urgent client',
	group = 'client'
}),
awful.key({modkey}, 'Tab',
	function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, {
		description = 'Focus previous client',
		group = 'client'
	}
),
awful.key({altkey}, 'Tab',
	function()
		switcher.switch( 1, altkey, 'Alt_L', shift, 'Tab')
	end, {
		description = 'switch window focus',
		group = 'client'
	}
),

-- Standard program
awful.key({modkey}, 't',
	function()
		awful.spawn(terminal)
	end, {
		description = 'Open a terminal',
		group = 'launcher'
	}
),
awful.key({modkey, altkey}, 'r', awesome.restart, {
	description = 'Restart/Reload awesome',
	group = 'awesome'
}),
awful.key({ modkey, shift   }, 'q', function()
	awesome.quit()
end, {
	description = 'Exit awesome',
	group = 'awesome'
}),

awful.key({modkey}, 'l',
	function()
		awful.tag.incmwfact(0.05)
	end, {
		description = 'increase master width factor',
		group = 'layout'
	}
),
awful.key({modkey}, 'h',
	function()
		awful.tag.incmwfact(-0.05)
	end, {
		description = 'decrease master width factor',
		group = 'layout'
	}
),
awful.key({modkey, shift}, 'h',
	function()
		awful.tag.incnmaster(1, nil, true)
	end, {
		description = 'increase the number of master clients',
		group = 'layout'
	}
),
awful.key({modkey, shift}, 'l',
	function()
		awful.tag.incnmaster(-1, nil, true)
	end, {
		description = 'decrease the number of master clients',
		group = 'layout'
	}
),
awful.key({modkey, control}, 'h',
	function()
		awful.tag.incncol(1, nil, true)
	end, {
		description = 'increase the number of columns',
		group = 'layout'
	}
),
awful.key({modkey, control}, 'l',
	function()
		awful.tag.incncol(-1, nil, true)
	end, {
		description = 'decrease the number of columns',
		group = 'layout'
	}
),
awful.key({modkey}, 'space',
	function()
		awful.layout.inc(1)
	end, {
		description = 'select next',
		group = 'layout'
	}
),
awful.key({modkey, shift}, 'space',
	function()
		awful.layout.inc(-1)
	end, {
		description = 'select previous',
		group = 'layout'
	}
),

awful.key({modkey, control}, 'n',
	function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal('request::activate', 'key.unminimize', {raise = true})
		end
	end, {
		description = 'restore minimized',
		group = 'client'
	}
))

clientkeys = gears.table.join(
awful.key({modkey}, 'f',
	function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, {
		description = 'toggle fullscreen',
		group = 'client'
	}
),
awful.key({ modkey, shift}, 'c',
	function(c)
		c:kill()
	end, {
		description = 'Close a client/window',
		group = 'client'
	}
),
awful.key({modkey, control}, 'space', awful.client.floating.toggle, {
		description = 'toggle floating', group = 'client'
	}
),
awful.key({modkey, control}, 'Return',
	function(c)
		c:swap(awful.client.getmaster())
	end, {
		description = 'move to master', group = 'client'
	}
),
awful.key({ modkey}, 'o',
	function(c)
		c:move_to_screen()
	end, {
		description = 'move to screen',
		group = 'client'
	}
),
awful.key({modkey, shift}, 't',
	function(c)
		c.ontop = not c.ontop
	end, {
		description = 'toggle keep on top',
		group = 'client'
	}
),
awful.key({modkey}, 'n',
	function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, {
		description = 'minimize',
		group = 'client'
	}
),
awful.key({modkey}, 'm', helpers.maximize, {
	description = '(un)maximize', group = 'client'
}),
awful.key({modkey, control}, 'm',
	function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, {
		description = '(un)maximize vertically',
		group = 'client'
	}
),
awful.key({modkey, shift}, 'm',
	function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, {
		description = '(un)maximize horizontally', group = 'client'
	}
))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(globalkeys,
		-- View tag only.
		awful.key({ modkey }, '#' .. i + 9,
			function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					tag:view_only()
				end
			end, {
				description = 'View tag #' .. i,
				group = 'tag'
			}
		),
        -- Toggle tag display.
        awful.key({modkey, control}, '#' .. i + 9,
			function()
				local screen = awful.screen.focused()
				local tag = screen.tags[i]
				if tag then
					awful.tag.viewtoggle(tag)
				end
			end, {
				description = 'toggle tag #' .. i,
				group = 'tag'
			}
		),
        -- Move client to tag.
        awful.key({modkey, shift}, '#' .. i + 9,
			function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
							client.focus:move_to_tag(tag)
					end
				end
			end, {
				description = 'move focused client to tag #' .. i,
				group = 'tag'
			}
		),
        -- Toggle tag on focused client.
        awful.key({modkey, control, shift}, '#' .. i + 9,
			function()
				if client.focus then
					local tag = client.focus.screen.tags[i]
					if tag then
						client.focus:toggle_tag(tag)
					end
				end
			end, {
				description = 'toggle focused client on tag #' .. i,
				group = 'tag'
			}
		)
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function(c)
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
    end),
    awful.button({ modkey, altkey }, 1, function(c)
		local cgeo = c:geometry()
		if not c.floating then
			awful.client.floating.toggle(c)
			awful.placement.under_mouse(c)
			c:geometry(cgeo)
		end
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal('request::activate', 'mouse_click', {raise = true})
        awful.mouse.client.resize(c)
    end)
)

root.keys(globalkeys)
awful.mouse.append_global_mousebinding(awful.button({ }, 3, function() mainmenu:toggle() end))

