local awful = require 'awful'
local wibox = require 'wibox'
local gears = require 'gears'
local beautiful = require 'beautiful'
local taglist = require 'ui.taglist-modern'
local widgets = require 'ui.widgets'
local harmony = require 'ui.components.harmony'
local helpers = require 'helpers'
local rubato = require 'libs.rubato'
local quickSettings = require 'ui.widgets.quickSettings'
--local filters = require 'surface_filters'

local Color = require 'lua-color'

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
		widgets.battery {size = beautiful.dpi(15)},
		widgets.icon('wifi', {size = beautiful.dpi(15)}),
		widgets.volume {size = beautiful.dpi(15)},
	}
	local controls = backgroundBar(controlsRaw)
	helpers.onLeftClick(controls, quickSettings.toggle)
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

	local mw, width, height = music.new {
		bg = '#00000000',
		shape = helpers.rrect(16),
		fg_sec = beautiful.fg_normal,
	}

	local titlebar, titleHeight = harmony.titlebar 'Music'
	local musicDisplay = wibox {
		width = beautiful.dpi(480),
		height = beautiful.dpi(180) + titleHeight,
		bg = '#00000000',
		ontop = true,
		visible = false
	}

	local titlebarColor = Color('#0f0f1f')
	local _, titlebarColorSat, titlebarColorVal = titlebarColor:hsv()

	local function makeGradient(solid, transparent)
		return {
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
						0,
						solid
					},
					{
						0.3,
						 solid .. 'e6'
					},
					{
						0.5,
						solid .. '99'
					},
					{
						0.7,
						solid .. 'cc'
					},
					{
						0.9,
						 solid .. 'e6'
					},
					{
						1,
						solid
					}
				}
			}
	end
	local gradient = wibox.widget {
		widget = wibox.container.background,
		bg = makeGradient(beautiful.bg_sec, beautiful.bg_sec)
	}

	local oldMusicColors = {
		gradient = Color(beautiful.bg_sec),
		shuffle = Color(beautiful.accent)
	}

	local albumColors = {}
	local oldMetadata = {}
	local expectedColors = 0
	pctl.listenMetadata(function (title, artist, art, album)
		if oldMetadata.artist == artist and oldMetadata.album == album then return end

		oldMetadata.artist = artist
		oldMetadata.album = album

		albumArt.image = gears.surface.load_uncached_silently(art)
		albumColors = {}

		awful.spawn.with_line_callback(string.format('magick %s -colors 5 -unique-colors txt:', art), {
			stdout = function(out)
				local enumAmount = out:match 'ImageMagick pixel enumeration: (%d),'
				if enumAmount then expectedColors = tonumber(enumAmount) end

				local idx = tonumber(out:match '^%d')
				if not idx then return end
				idx = idx + 1

				albumColors[idx] = Color(out:match '#%x%x%x%x%x%x')

				if idx == expectedColors then
					local albumColorsValue = table.filter(albumColors, function(t)
						-- only for the background gradient: attempt to avoid black/white if others are available
						local _, s, v = t:hsv()
						if (v * 100) < 15 or (s * 100) < 15 then
							print(string.format('goodbye to the color that is %s', t))
							return false
						end
						return true
					end)

					-- copy without reference to other table (to not mess up gradient)
					local albumColorsLight = {}
					--for k, v in pairs(albumColors) do albumColorsLight[k] = v end
					if #albumColorsValue > 3 then
						for k, v in pairs(albumColorsValue) do albumColorsLight[k] = v end
					else
						for k, v in pairs(albumColors) do albumColorsLight[k] = v end
					end
					table.sort(albumColorsLight, function(c1, c2)
						local _, _, l1 = c1:hsla()
						local _, _, l2 = c2:hsla()

						return l1 > l2
					end)

					-- TODO: next sort by color value?

					local gradientColor = albumColors[1]
					local shuffleColor = albumColors[1]
					if #albumColorsValue > 4 then
						gradientColor = albumColorsValue[1]
					end
					--[[
					require 'naughty'.notify {
						title = 'hi!',
						text = string.format('gradient color is %s, ones with value are %s', gradientColor, tostring(#albumColorsValue))
					}
					]]--

					local titlebarBg = titlebar:get_children_by_id'bg'[1]
					local animator = rubato.timed {
						duration = 3,
						rate = 60,
						override_dt = false,
						subscribed = function(perc)
							local mixedColor = oldMusicColors.gradient:mix(gradientColor, perc / 100)
							local mixedColorHue = mixedColor:hsv()
							titlebarBg.bg = tostring(Color {h = mixedColorHue, s = titlebarColorSat, v = titlebarColorVal})
							gradient.bg = makeGradient(tostring(mixedColor), beautiful.bg_sec)
							mw.setColors {
								--shuffle = tostring(oldMusicColors.shuffle:mix(shuffleColor, perc / 100))
								--shuffle = helpers.invertColor(tostring(shuffleColor), true)
								shuffle = albumColorsLight[1]
							}

							if perc == 100 then
								oldMusicColors.gradient = gradientColor
								oldMusicColors.shuffle = albumColors[3]
							end
						end,
						pos = 0,
						easing = {
							F = 1/3, -- F(1) = 1/3
							easing = function(t) return t*t end -- f(x) = x^2, I just use t for "time"
						}
					}
					if musicDisplay.displayed then
						animator.target = 100
					else
						local gradientColorHue = gradientColor:hsv()
						titlebarBg.bg = tostring(Color {h = gradientColorHue, s = titlebarColorSat, v = titlebarColorVal})
						gradient.bg = makeGradient(tostring(gradientColor), beautiful.bg_sec)
						mw.setColors {
							--shuffle = tostring(oldMusicColors.shuffle:mix(shuffleColor, perc / 100))
							--shuffle = helpers.invertColor(tostring(shuffleColor), true)
							shuffle = shuffleColor
						}

						oldMusicColors.gradient = gradientColor
						oldMusicColors.shuffle = albumColors[3]
					end

					-- {{
					-- for now, this part is a bit meh and actually causes
					-- WORSE colors for the progress bar. funny huh, when the table is for
					-- colors with better values.
					local progressColors = {albumColors[3], albumColors[2]}
					if #albumColorsValue > 3 then
						progressColors = {albumColorsValue[3], albumColorsValue[2]}
					end
					-- }}

					mw.setColors {
						--position = helpers.invertColor(albumColors[1], true),
						--album = helpers.invertColor(albumColors[1], true),
						progress = {
							tostring(albumColorsLight[1]),
							tostring(albumColorsLight[2]),
						}
					}
				end
			end,
			exit = function(reason, code)
				if reason == 'exit' and code == 0 then
					-- was doing the colors here but albumColors is length 0 for some reason (???)
				end
			end
		})
	end)

	musicDisplay:setup {
		widget = wibox.container.background,
		shape = helpers.rrect(beautiful.radius),
		{
			layout = wibox.layout.fixed.vertical,
			titlebar,
			{
				layout = wibox.layout.stack,
				--[[
				{
					widget = filters.blur,
					dual_pass = false,
					radius = 5,
					albumArt,
				},
				]]--
				albumArt,
				gradient,
				mw
			}
		}
	}
	helpers.slidePlacement(musicDisplay, {placement = 'bottom_right'})

	local musicBtn = widgets.button('music', {
		bg = beautiful.wibar_bg,
		onClick = function() musicDisplay:toggle() end
	})

	local sm = require 'ui.widgets.startMenu'
	local startMenu = sm.create {
		bg = beautiful.bg_normal,
	--	shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, true, true, base.radius) end
	}
	sm.bindMethods(startMenu)
	
	local startMenu = widgets.button(beautiful.os_icon, {
		onClick = function() startMenu:toggle() end,
		size = beautiful.dpi(25),
		shape = gears.shape.rectangle,
		color = beautiful.accent
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

	local realbar = {
		widget = wibox.container.background,
		bg = beautiful.bg_normal,
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

