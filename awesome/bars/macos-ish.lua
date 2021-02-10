-- TODO: Make it more MacOS :)
-- actually make it 2 bars
local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local text_taglist = require("taglist")

-- {{{ Wibar
-- Create a textclock widget
textclock = wibox.widget.textclock()
textclock.format = "%I:%M %p"

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
					awful.button({ }, 1, function(t) t:view_only() end),
					awful.button({ modkey }, 1, function(t)
											  if client.focus then
												  client.focus:move_to_tag(t)
											  end
										  end),
					awful.button({ }, 3, awful.tag.viewtoggle),
					awful.button({ modkey }, 3, function(t)
											  if client.focus then
												  client.focus:toggle_tag(t)
											  end
										  end),
					awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
					awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
				)

local tasklist_buttons = gears.table.join(
					 awful.button({ }, 1, function (c)
											  if c == client.focus then
												  c.minimized = true
											  else
												  c:emit_signal(
													  "request::activate",
													  "tasklist",
													  {raise = true}
												  )
											  end
										  end),
					 awful.button({ }, 3, function()
											  awful.menu.client_list({ theme = { width = 250 } })
										  end),
					 awful.button({ }, 4, function ()
											  awful.client.focus.byidx(1)
										  end),
					 awful.button({ }, 5, function ()
											  awful.client.focus.byidx(-1)
										  end))

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
						   awful.button({ }, 1, function () awful.layout.inc( 1) end),
						   awful.button({ }, 3, function () awful.layout.inc(-1) end),
						   awful.button({ }, 4, function () awful.layout.inc( 1) end),
						   awful.button({ }, 5, function () awful.layout.inc(-1) end)))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist {
		screen  = s,
		filter  = awful.widget.taglist.filter.all,
		buttons = taglist_buttons
	}


	-- Create the wibox
	s.mywibox = awful.wibar({ screen = s, height = 24, width = s.geometry.width - 36, shape = gears.shape.rounded_rect })
	s.mywibox.y = s.geometry.height-36

	-- Add widgets to the wibox
	s.mywibox:setup {
		layout = wibox.layout.stack,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			text_taglist(s),
		},
		{
			s.mytasklist,
			valign = "center",
			halign = "center",
			layout = wibox.container.place
		}, -- Middle widget
		nil, -- Right widgets
	}
end)
-- }}}