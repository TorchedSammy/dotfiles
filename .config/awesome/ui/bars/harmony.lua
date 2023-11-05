local awful = require 'awful'
local wibox = require 'wibox'
local gears = require 'gears'
local beautiful = require 'beautiful'
local taglist = require 'ui.taglist-modern'
local widgets = require 'ui.widgets'
local helpers = require 'helpers'
local rubato = require 'libs.rubato'
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
			widget = wibox.container.background,
			bg = beautiful.xcolor8,
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
		widgets.icon('battery', {size = beautiful.dpi(15)}),
		widgets.icon('wifi', {size = beautiful.dpi(15)}),
		widgets.icon('volume', {size = beautiful.dpi(15)}),
	}
	local controls = backgroundBar(controlsRaw)
	--helpers.onLeftClick(controls, w.quickSettings.toggle)
	helpers.displayClickable(controls, {bg = beautiful.xcolor8, hoverColor = beautiful.xcolor9})

	local music = require 'ui.widgets.musicDisplay'
	local pctl = require 'modules.playerctl'

	local albumArt = wibox.widget {
		widget = wibox.widget.imagebox,
		horizontal_fit_policy = "cover",
		vertical_fit_policy = "cover",
		valign = 'center',
		halign = 'center',
	}
	local albumColors = {}

	local mw, width, height = music.new {
		bg = '#00000000',
		shape = helpers.rrect(16),
		fg_sec = beautiful.fg_normal
	}

	local musicDisplay = wibox {
		width = beautiful.dpi(480),
		height = beautiful.dpi(180),
		bg = '#00000000',
		shape = helpers.rrect(6),
		ontop = true,
		visible = false
	}

	local gradient = wibox.widget {
			widget = wibox.container.background,
			bg = {
				type  = 'linear' ,
				from  = {
					0,
					musicDisplay.height
				},
				to = {
					musicDisplay.width,
					musicDisplay.height
				},
				stops = {
					{
						0.2,
						beautiful.bg_sec
					},
					{
						1,
						beautiful.bg_sec .. '55'
					}
				}
			}
		}

	local Color = require 'lua-color'
	local oldMusicColors = {
		gradient = Color(beautiful.bg_sec),
		shuffle = Color(beautiful.accent)
	}

	pctl.listenMetadata(function (title, artist, art, album)
		albumArt.image = gears.surface.load_uncached_silently(art)
		albumColors = {}

		awful.spawn.with_line_callback(string.format('magick %s -colors 5 -unique-colors txt:', art), {
			stdout = function(out)
				local idx = tonumber(out:match '^%d') + 1
				albumColors[idx] = out:match '#%x%x%x%x%x%x'

				if idx == 3 then
					local gradientColor = Color(albumColors[1])
					local shuffleColor = Color(albumColors[1])

					local animator = rubato.timed {
						duration = 2,
						rate = 60,
						override_dt = false,
						subscribed = function(perc)
							gradient.bg = {
								type  = 'linear' ,
								from  = {
									0,
									musicDisplay.height
								},
								to = {
									musicDisplay.width,
									musicDisplay.height
								},
								stops = {
									{
										0.2,
										tostring(oldMusicColors.gradient:mix(gradientColor, perc / 100))
									},
									{
										1,
										beautiful.bg_sec .. '55'
									}
								}
							}
							mw.setColors {
								--shuffle = tostring(oldMusicColors.shuffle:mix(shuffleColor, perc / 100))
								--shuffle = helpers.invertColor(tostring(shuffleColor), true)
							}

							if perc == 100 then
								oldMusicColors.gradient = Color(albumColors[1])
								oldMusicColors.shuffle = Color(albumColors[3])
							end
						end,
						pos = 0,
						easing = rubato.quadratic
					}
					animator.target = 100
				end

				if albumColors[2] then
					mw.setColors {
						--position = helpers.invertColor(albumColors[1], true),
						--album = helpers.invertColor(albumColors[1], true),
						progress = {
							albumColors[3],
							albumColors[2],
						}
					}
				end
			end,
			exit = function(reason, code)
				if reason == 'exit' and code == 0 then
					--[[
					gradient.bg = {
					type  = 'linear' ,
					from  = {
						0,
						musicDisplay.height
					},
					to = {
						musicDisplay.width,
						musicDisplay.height
					},
					stops = {
						{
							0.2,
							albumColors[1]
						},
						{
							1,
							beautiful.bg_sec .. '55'
						}
					}
				}
					]]
				end
			end
		})
	end)

	musicDisplay:setup {
		layout = wibox.layout.stack,
		albumArt,
		gradient,
		mw
	}
	helpers.slidePlacement(musicDisplay, {placement = 'bottom_right'})

	local musicBtn = widgets.button('music', {
		bg = beautiful.wibar_bg,
		onClick = function() musicDisplay:toggle() end
	})

	local sm = require 'ui.widgets.startMenu'
	local startMenu = sm.create {
		bg = beautiful.bg_sec,
	--	shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, true, true, base.radius) end
	}
	sm.bindMethods(startMenu)
	
	local startMenu = widgets.button(beautiful.os_icon, {
		bg = beautiful.wibar_bg,
		onClick = function() startMenu:toggle() end
	})

	local baseClientIndicator = {
		height = beautiful.dpi(3),
		width = beautiful.dpi(3)
	}
	local clientIndicatorShift = beautiful.dpi(6)

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
		style = {
			bg_normal = beautiful.fg_tert,
			bg_focus = beautiful.accent,
			bg_minimize = beautiful.fg_tert,
			shape = helpers.rrect(6)
		},
		widget_template = {
			widget = wibox.container.place,
			{
				layout = wibox.layout.fixed.vertical,
				spacing = beautiful.dpi(4),
				{
					layout = wibox.container.constraint,
					strategy = 'exact',
					width = beautiful.dpi(25),
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

	local realbar = {
		widget = wibox.container.background,
		bg = beautiful.bg_normal,
		{
			widget = wibox.container.margin,
			margins = beautiful.dpi(8),
			{	
				layout = wibox.layout.align.horizontal,
				expand = 'none',
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
						widgets.systray {bg = beautiful.wibar_bg, bar = s.bar, margin = beautiful.dpi(8)},
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

