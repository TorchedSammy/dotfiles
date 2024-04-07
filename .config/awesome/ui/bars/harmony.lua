local awful = require 'awful'
local wibox = require 'wibox'
local gears = require 'gears'
local beautiful = require 'beautiful'
local taglist = require 'ui.taglist-modern'
local widgets = require 'ui.widgets'
local harmony = require 'ui.components.harmony'
local helpers = require 'helpers'
local rubato = require 'libs.rubato'
local quickSettings = require 'ui.panels.quickSettings'
local makeup = require 'ui.makeup'
--local filters = require 'surface_filters'

screen.connect_signal('property::geometry', helpers.set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	s.bar = awful.wibar({
		screen = s,
		position = 'bottom',
		height = beautiful.wibar_height,
		width = s.geometry.width,
		bg = '#00000000'
	})

	local actionBtn = widgets.button('actionCenter', {
		bg = beautiful.bg_normal_opposite,
		size = beautiful.dpi(16),
		--onClick = w.quickSettings.toggle
	})

	local function backgroundBar(w)
		return wibox.widget {
			widget = makeup.putOn(wibox.container.background, {bg = 'bg_sec'}),
			shape = gears.shape.rounded_bar,
			id = 'bg',
			{
				widget = wibox.container.margin,
				margins = beautiful.dpi(6),
				w
			}
		}
	end

	local controlsRaw = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		spacing = 5,
		widgets.battery {size = beautiful.dpi(15)},
		widgets.wifi {size = beautiful.dpi(15)},
		widgets.volume {size = beautiful.dpi(15)},
	}
	local controls = backgroundBar(controlsRaw)
	helpers.onLeftClick(controls, quickSettings.toggle)
	helpers.displayClickable(controls, {bg = 'bg_sec', hoverColor = 'bg_tert'})

	--local musicDisplay = require 'ui.panels.musicDisplay.material'
	local musicDisplay = require 'ui.panels.musicDisplay'.create {
		bg = beautiful.bg_popup
	}
	helpers.slidePlacement(musicDisplay, {placement = 'bottom_right'})

	local musicBtn = widgets.button('music', {
		bg = 'wibar_bg',
		onClick = function() musicDisplay:toggle() end
	})

	local sm = require 'ui.panels.startMenu'
	local startMenu = sm.create {
	--	shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, true, true, base.radius) end
	}
	sm.bindMethods(startMenu)
	
	local startMenu = widgets.button(beautiful.os_icon, {
		onClick = function() startMenu:toggle() end,
		size = beautiful.dpi(25),
		shape = gears.shape.rectangle,
		color = 'accent'
	})

	local baseClientIndicator = {
		height = beautiful.dpi(3),
		width = beautiful.dpi(3)
	}
	local clientIndicatorShift = beautiful.dpi(10)

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
			spacing = beautiful.wibar_spacing,
			layout  = wibox.layout.fixed.horizontal
		},
		style = setmetatable({}, {
			__index = function(_, k)
				local styles = {
					bg_normal = beautiful.fg_tert,
					bg_focus = beautiful.accent,
					bg_minimize = beautiful.fg_tert,
					shape = helpers.rrect(6)
				}

				return styles[k]
			end
		}),
		widget_template = {
			widget = wibox.container.place,
			{
				layout = wibox.layout.fixed.vertical,
				spacing = beautiful.dpi(4),
				{
					layout = wibox.container.constraint,
					strategy = 'exact',
					width = beautiful.dpi(26.5),
					{
						layout = wibox.container.place,
						{
							awful.widget.clienticon,
							id = 'clienticon',
							--margins = beautiful.dpi(4),
							widget = wibox.container.margin
						},
					},
				},
				{
					layout = wibox.container.margin,
					bottom = -4,
					{
						
					layout = wibox.container.place,
					{
						wibox.widget.base.make_widget(),
						id = 'background_role',
						forced_width = baseClientIndicator.width,
						forced_height = baseClientIndicator.height,
						widget = wibox.container.background,
					}
					}
				},
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
					pos = baseClientIndicator.width,
					subscribed = function(w)
						bgW.forced_width = w
					end
				}

				function self.update()
					if client.focus == c then
						animator.target = baseClientIndicator.width + clientIndicatorShift
					else
						animator.target = baseClientIndicator.width
					end
				end

				self.update()
			end,
			update_callback = function(self)
				self.update()
			end
		},
	}
	awesome.connect_signal('makeup::put_on', function()
		s.tasklist._do_tasklist_update()
	end)

	local realbar = {
		widget = makeup.putOn(wibox.container.background, {bg = 'wibar_bg'}),
		{
			widget = wibox.container.margin,
			margins = beautiful.dpi(8),
			{	
				layout = wibox.layout.align.horizontal,
				{
					
					{ -- First bar
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.wibar_spacing,
						startMenu,
						backgroundBar(taglist(s)),
						s.tasklist
					},
					left = beautiful.useless_gap,
					right = beautiful.wibar_spacing,
					widget = wibox.container.margin,
				},
				{
					{ -- First bar
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.wibar_spacing,
						--taglist(s),
					},
					left = beautiful.wibar_spacing,
					right = beautiful.wibar_spacing,
					widget = wibox.container.margin,
				},
				{
					{ -- First bar
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.wibar_spacing,
						widgets.systray {bg = 'wibar_bg', bar = s.bar, margin = beautiful.dpi(8)},
						musicBtn,
						controls,
						widgets.textclock,
						widgets.layout(s, beautiful.dpi(15))
					},
					left = beautiful.wibar_spacing,
					right = beautiful.useless_gap,
					widget = wibox.container.margin,
				},
			}
		}
	}

	s.bar:setup(realbar)
end)

