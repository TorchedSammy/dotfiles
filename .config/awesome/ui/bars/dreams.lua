local awful = require 'awful'
local beautiful = require 'beautiful'
local common = require 'awful.widget.common'
local gears = require 'gears'
local helpers = require 'helpers'
local rubato = require 'libs.rubato'
local taglist = require 'ui.taglist-modern'
local wibox = require 'wibox'
local widgets = require 'ui.widgets'

local music = require 'ui.widgets.musicDisplay'
local musicWibox = music.create {
	bg = beautiful.bg_popup,
	placement = function(c)
		awful.placement.align(c, {
			position = 'top',
			margins = {
				top = beautiful.wibar_height + beautiful.useless_gap * beautiful.dpi(3)
			},
			parent = awful.screen.focused()
		})
	end
}

awful.screen.connect_for_each_screen(function(s)
	s.bar = awful.wibar({
		screen = s,
		position = 'top',
		height = beautiful.wibar_height,
		width = s.geometry.width,
		bg = '#00000000'
	})

	s.sidebar = awful.wibar({
		screen = s,
		position = 'left',
		width = beautiful.wibar_height,
		height = s.geometry.height - beautiful.wibar_height,
		bg = '#00000000'
	})

	local baseClientIndicator = {
		height = beautiful.dpi(24),
		width = beautiful.dpi(3)
	}

	local bling = require 'libs.bling'
	bling.widget.task_preview.enable {
		widget_structure = {
			layout = wibox.layout.fixed.vertical,
			spacing = beautiful.dpi(5),
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.dpi(5),
				{
                    id = 'icon_role',
                    widget = awful.widget.clienticon,
                },
                {
                    id = 'name_role',
                    widget = wibox.widget.textbox,
                },
			},
			{
				id = 'image_role', -- The client preview
				resize = true,
				valign = 'center',
				halign = 'center',
				widget = wibox.widget.imagebox,
			},
		},
		placement_fn = function(c)
			awful.placement.next_to(c, {
				geometry = mouse.current_widget_geometry,
				preferred_positions = 'right',
				preferred_anchors = 'middle',
				margins = {
					left = beautiful.useless_gap
				}
			})
		end
	}

	s.tasklist = awful.widget.tasklist {
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = gears.table.join(
			awful.button({}, 1, function (c)
				if c == client.focus then
					c.minimized = true
				else
					c:emit_signal('request::activate', 'tasklist', {
						raise = true
					})
				end
			end),

			awful.button({}, 4, function()
				awful.client.focus.byidx(1)
			end),

			awful.button({}, 5, function()
				awful.client.focus.byidx(-1)
			end)
		),
		layout = {
			spacing = beautiful.dpi(8),
			layout  = wibox.layout.fixed.vertical
		},
		style = {
			bg_normal = beautiful.fg_tert,
			bg_focus = beautiful.accent,
			bg_minimize = beautiful.fg_tert,
			shape = helpers.rrect(6)
		},
		widget_template = {
			widget = wibox.container.margin,
			margins = beautiful.dpi(2),
			{
				widget = wibox.container.background,
				--bg = beautiful.bg_sec,
				shape = helpers.rrect(2),
				{
					widget = wibox.container.margin,
					margins = beautiful.dpi(2),
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.dpi(4),
						{
							layout = wibox.container.place,
							{
								wibox.widget.base.make_widget(),
								id = 'background_role',
								forced_width = baseClientIndicator.width,
								forced_height = baseClientIndicator.height,
								widget = wibox.container.background,
							}
						},
						{
							layout = wibox.container.constraint,
							strategy = 'exact',
							width = beautiful.dpi(24),
							{
								layout = wibox.container.place,
								{
									awful.widget.clienticon,
									id = 'clienticon',
									--margins = beautiful.dpi(4),
									widget = wibox.container.margin
								}
							}
						},
					}
				}
			},
			create_callback = function(self, c)
				self:connect_signal('mouse::enter', function()
					awesome.emit_signal('bling::task_preview::visibility', s, true, c)
				end)
				self:connect_signal('mouse::leave', function()
					awesome.emit_signal('bling::task_preview::visibility', s, false, c)
				end)

				local bgW = self:get_children_by_id 'background_role'[1]
				local animator = rubato.timed {
					intro = 0.02,
					duration = 0.25,
					override_dt = false,
					subscribed = function(h)
						bgW.forced_height = h
					end
				}

				function self.update()
					if client.focus == c then
						animator.target = baseClientIndicator.height
					else
						animator.target = baseClientIndicator.height / 2
					end
				end

				self.update()
			end,
			update_callback = function(self)
				self.update()
			end
		},
	}

	local minimize = widgets.button('minimize', {
		bg = beautiful.bg_normal,
		-- size = btnSize,
		onClick = function() client.focus.minimized = true end
	})

	local maximize = widgets.button('expand-more', {
		bg = beautiful.bg_normal,
		-- size = btnSize,
		onClick = function() helpers.maximize(client.focus) end
	})

	local close = widgets.button('close', {
		bg = beautiful.bg_normal,
		-- size = btnSize,
		onClick = function() client.focus:kill() end
	})
	
	local winControls = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		minimize,
		maximize,
		close
	}

	local music = widgets.music
	music.buttons = {
		awful.button({}, 1, function()
			musicWibox.toggle()
		end),
	}

	local bar = {
		--direction = 'east',
		widget = wibox.container.rotate,
		{
			widget = wibox.container.background,
			bg = beautiful.bg_normal,
			{
				layout = wibox.layout.align.horizontal,
				expand = 'none',
				{
					{ -- First bar
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.wibar_spacing,
						widgets.icon(beautiful.os_icon),
					},
					left = beautiful.wibar_spacing,
					right = beautiful.wibar_spacing,
					widget = wibox.container.margin,
				},
				{
					{ -- First bar
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.wibar_spacing,
						music,
					},
					left = beautiful.wibar_spacing,
					right = beautiful.wibar_spacing,
					widget = wibox.container.margin,
				},
				{
					{ -- First bar
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.wibar_spacing,
						winControls
					},
					left = beautiful.wibar_spacing,
					right = beautiful.wibar_spacing,
					widget = wibox.container.margin,
				},
			}
		}
	}

	local side = {
		widget = wibox.container.background,
		bg = beautiful.bg_normal,
		{
			layout = wibox.layout.align.vertical,
			expand = 'none',
			{
				{ -- First bar
					layout = wibox.layout.fixed.vertical,
					spacing = beautiful.wibar_spacing,
					taglist(s, true),
					s.tasklist
				},
				top = beautiful.wibar_spacing,
				bottom = beautiful.wibar_spacing,
				widget = wibox.container.margin,
			},
			{
				{ -- First bar
					layout = wibox.layout.fixed.vertical,
					spacing = beautiful.wibar_spacing,
				},
				top = beautiful.wibar_spacing,
				bottom = beautiful.wibar_spacing,
				widget = wibox.container.margin,
			},
			{
				{ -- First bar
					layout = wibox.layout.fixed.vertical,
					spacing = beautiful.wibar_spacing,
					widgets.icon 'battery',
					widgets.systray {
						bg = beautiful.bg_normal,
						vertical = true,
						bar = s.sidebar
					},
					widgets.layout(s)
				},
				top = beautiful.wibar_spacing,
				bottom = beautiful.wibar_spacing,
				widget = wibox.container.margin,
			},
		}
	}

	s.bar:setup(bar)
	s.sidebar:setup(side)
end)

