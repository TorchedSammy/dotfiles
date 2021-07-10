local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local naughty = require 'naughty'
local taglist = require 'ui.taglist'
local widgets = require 'ui.widgets'
local wibox = require 'wibox'

screen.connect_signal('property::geometry', helpers.set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	helpers.set_wallpaper(s)

	-- Our actual bar will be transparent,
	-- then we add the smaller bars inside of it
	s.bar = awful.wibar {
		screen = s,
		position = 'top',
		height = beautiful.wibar_height,
		width = s.geometry.width - 28,
		shape = gears.shape.rounded_rect, -- to change the shape of the bars, change here
		bg = '#00000000' -- make it transparent black
	}

	s.bar.y = 10
	s.bar.pillshape = gears.shape.rounded_bar

	-- First bar: workspaces
	local workspaces = wibox.widget {
		{
			{
				layout = wibox.layout.fixed.horizontal,
				taglist(s)	
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
			up = 4
		},
		shape = s.bar.pillshape,
		bg = beautiful.bg_sec,
		widget = wibox.container.background,
	}

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

	local rawtasklist = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons  = tasklist_buttons,
		style = {
			shape = gears.shape.rounded_bar,
			bg_normal = beautiful.bg_sec,
			bg_focus = beautiful.bg_sec
		},
		layout = {
			spacing = 14,
			layout = wibox.layout.flex.horizontal
		},
		widget_template = {
    	    {
	            {
        	        id     = 'clienticon',
    	            widget = awful.widget.clienticon,
	            },
    	        widget  = wibox.container.margin
	        },
        	nil,
    	    create_callback = function(self, c, index, objects) --luacheck: no unused args
	            self:get_children_by_id('clienticon')[1].client = c
        	end,
    	    layout = wibox.layout.align.vertical,
	    },
	}
	local tasklist = wibox.widget {
		{
			{
				layout = wibox.layout.fixed.horizontal,
				rawtasklist
			},
			top = 2, bottom = 2,
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		shape = s.bar.pillshape,
		bg = beautiful.bg_sec,
		widget = wibox.container.background,
	}

	local music = wibox.widget {{
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = 5,
				widgets.music,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		},
		shape = s.bar.pillshape,
		bg = beautiful.bg_sec,
		widget = wibox.container.background,
	}

	local time = wibox.widget {{
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
			layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				widgets.time
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}},
		shape = s.bar.pillshape,
		bg = beautiful.bg_sec,
		widget = wibox.container.background,
	}

	local icons = wibox.widget {{
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
			layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				wibox.widget {
					widgets.raw_systray,
					top = 5,
					bottom = 5,
					widget = wibox.container.margin
				},
				widgets.layout
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}},
		shape = s.bar.pillshape,
		bg = beautiful.bg_sec,
		widget = wibox.container.background,
	}

	local realbar = wibox.widget {{
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
				layout = wibox.layout.fixed.horizontal,
				workspaces
			},
			top = 5, bottom = 5,
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,

		},
		{
			{ -- Middle widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				tasklist,
			},
			top = 5, bottom = 5,
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{ -- Right widgets
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				music,
				time,
				icons
			},
			top = 5, bottom = 5,
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		},
		shape = s.bar.shape,
		bg = beautiful.wibar_bg,
		widget = wibox.container.background,
		forced_width = s.geometry.width
	}
	
	s.bar:setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				realbar,
			},
			left = 1, right = 1,
			widget = wibox.container.margin,
		}
	}
end)
