-- Bottom Bar inspired by woolenkitten
local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local text_taglist = require("taglist")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")

local systray_margin = (beautiful.wibar_height-beautiful.systray_icon_size)/2

local function rounded_bar(color)
    return wibox.widget {
        max_value     = 100,
        value         = 0,
        forced_height = dpi(10),
        forced_width  = dpi(60),
        margins       = {
          top = dpi(10),
          bottom = dpi(10),
        },
        shape         = gears.shape.rounded_bar,
        border_width  = 1,
        color         = color,
        background_color = beautiful.bg_normal,
        border_color  = beautiful.border_normal,
        widget        = wibox.widget.progressbar,
    }
end

-- Ram bar
local ram_bar = rounded_bar(beautiful.ram_bar_color)

awful.widget.watch("cat /proc/meminfo", 5, function(widget, stdout)
  local total = stdout:match("MemTotal:%s+(%d+)")
  local free = stdout:match("MemFree:%s+(%d+)")
  local buffers = stdout:match("Buffers:%s+(%d+)")
  local cached = stdout:match("Cached:%s+(%d+)")
  local srec = stdout:match("SReclaimable:%s+(%d+)")
  local used_kb = total - free - buffers - cached - srec
  widget.value = used_kb / total * 100
end, ram_bar)


local mysystray = wibox.widget.systray()
mysystray:set_base_size(beautiful.systray_icon_size)

systraycontainer = {
	mysystray,
		top = systray_margin,
    bottom = systray_margin,
    right = 5,
    left = 5,
    widget = wibox.container.margin
}

time = wibox.widget.textclock()
time.format = "  %I:%M %p"

date = wibox.widget.textclock()
date.format = "%d/%m/%y"

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

screen.connect_signal("property::geometry", set_wallpaper)


music = wibox.widget {
	markup = '  Nothing Playing',
	widget = wibox.widget.textbox
}

awful.screen.connect_for_each_screen(function(s)
	set_wallpaper(s)

	local l = awful.layout.suit
	local layouts = { l.floating, l.spiral.dwindle, l.floating, l.tile, l.floating, l.floating, l.floating, l.floating, l.floating }
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, layouts)

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
	s.systray = mysystray

	-- Create the wibox
	s.bar = awful.wibar({ screen = s, position = "bottom", height = beautiful.wibar_height, bg = beautiful.wibar_bg })
	s.topbar = awful.wibar({ screen = s, position = "top", height = beautiful.wibar_height, bg = beautiful.wibar_bg })

	s.topbar:setup {
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				music
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{ -- Middle widget
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}, -- Middle widget
		{
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				time,
				{
					s.mylayoutbox,
					top = 8, bottom = 8,
	        widget = wibox.container.margin
				}
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
	}

	-- Add widgets to the wibox
	s.bar:setup {
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{
			{ -- Left widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				text_taglist(s),
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{ -- Middle widget
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				systraycontainer,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}, -- Middle widget
		{
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				ram_bar,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
	}

end)
-- }}}
