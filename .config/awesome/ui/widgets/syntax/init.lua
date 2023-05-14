local awful = require 'awful'
local base = require 'ui.components.syntax.base'
local beautiful = require 'beautiful'
local bling = require 'modules.bling'
local dpi = beautiful.dpi
local gears = require 'gears'
local helpers = require 'helpers'
local vol = require 'conf.vol'
local wibox = require 'wibox'
local w = require 'ui.widgets'
local naughty = require 'naughty'
local menugen = require 'menubar.menu_gen'
local rubato = require 'modules.rubato'
local settings = require 'conf.settings'

local bgcolor = beautiful.bg_sec
local playerctl = bling.signal.playerctl.lib()
local function button(color_focus, icon, size, shape)
	return w.button(icon, {bgcolor = bgcolor, shape = shape, size = size})
end

local widgets = {}

do
	local albumArt = wibox.widget {
		widget = wibox.widget.imagebox,
		resize = true
	}

	local musicArtist = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}

	local musicTitle = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}

	local musicAlbum = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}
	local positionText = wibox.widget {
		markup = '',
		widget = wibox.widget.textbox
	}

	local musicDisplay = wibox {
		width = dpi(480),
		height = dpi(180),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}
	helpers.hideOnClick(musicDisplay)

	local progressShape = base.shape
	local progress = wibox.widget {
		widget = wibox.widget.progressbar,
		border_color = beautiful.fg_sec,
		border_width = 1,
		forced_height = 18,
		paddings = 2,
		background_color = bgcolor,
		shape = progressShape,
		bar_shape = progressShape
	}
	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = progress.forced_height,
		bar_color = '#00000000'
	}
	slider:connect_signal('property::value', function()
		progress.value = slider.value
		playerctl:set_position(slider.value)
	end)


	local function scroll(widget)
		return wibox.widget {
			layout = wibox.container.scroll.horizontal,
			step_function = wibox.container.scroll.step_functions.nonlinear_back_and_forth,
			max_size = 50,
			speed = 80,
			widget
		}
	end

	local wrappedMusicArtist = scroll(musicArtist)
	local wrappedMusicTitle = scroll(musicTitle)
	local wrappedMusicAlbum = scroll(musicAlbum)
	local btnSize = beautiful.dpi(19)

	local shuffle = button(beautiful.fg_normal, 'shuffle', btnSize)
	local shuffleState
	local function updateShuffle()
		if shuffleState then
			shuffle.color = beautiful.xcolor2
		else
			shuffle.color = beautiful.fg_normal
		end
	end

	shuffle:connect_signal('button::press', function()
		shuffleState = not shuffleState
		playerctl:set_shuffle(shuffleState)
		updateShuffle()
	end)
	playerctl:connect_signal('shuffle', function(_, shuff)
		shuffleState = shuff
		updateShuffle()
	end)

	local position = 0
	local prev = button(beautiful.fg_normal, 'skip-previous', btnSize)
	prev:connect_signal('button::press', function()
		if position >= 5 then
			playerctl:set_position(0)
			position = 0
			return
		end
		playerctl:previous()
	end)

	local playPauseIcons = {'play', 'pause'}
	local playPause = button(beautiful.fg_normal, playPauseIcons[2], btnSize)
	playPause:connect_signal('button::press', function()
		playerctl:play_pause()
	end)

	local next = button(beautiful.fg_normal, 'skip-next', btnSize)
	next:connect_signal('button::press', function()
		playerctl:next()
	end)

	playerctl:connect_signal('metadata', function (_, title, artist, art, album)
		musicArtist:set_markup_silently(artist)
		wrappedMusicArtist:emit_signal 'widget::redraw_needed'

		musicTitle:set_markup_silently(title)
		wrappedMusicTitle:emit_signal 'widget::redraw_needed'

		musicAlbum:set_markup_silently(helpers.colorize_text(album, beautiful.fg_sec))
		wrappedMusicAlbum:emit_signal 'widget::redraw_needed'

		albumArt.image = gears.surface.load_uncached_silently(art, beautiful.config_path .. '/images/albumPlaceholder.png')
		positionText:set_markup_silently(helpers.colorize_text('0:00', beautiful.fg_sec))
	end)
	playerctl:connect_signal('position', function (_, pos, length)
		progress.color = string.format('linear:0,0:%s,0:0,%s:%s,%s', math.floor(length), base.gradientColors[1], math.floor(length), base.gradientColors[2])
		progress.max_value = length
		slider.maximum = length
		progress.value = pos
		position = pos

		local mins = math.floor(pos / 60)
		local secs = pos % 60
		local time = string.format('%01d:%02d', mins, secs)
		positionText:set_markup_silently(helpers.colorize_text(time, beautiful.fg_sec))
	end)
	playerctl:connect_signal('playback_status', function(_, playing)
		if not playing then
			playPause.icon = playPauseIcons[1]
		else
			playPause.icon = playPauseIcons[2]
		end
	end)

	local info = wibox.widget {
		layout = wibox.layout.ratio.vertical,
		{
			layout = wibox.layout.fixed.vertical,
			spacing = 6,
			wrappedMusicArtist,
			wrappedMusicTitle,
			wrappedMusicAlbum,
		},
		{
			layout = wibox.layout.align.horizontal,
			expand = 'none',
			{
				widget = wibox.container.margin,
				left = -beautiful.dpi(6),
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.wibar_spacing / beautiful.dpi(4),
					prev,
					playPause,
					next
				}
			},
			{
				layout = wibox.container.place
			},
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				shuffle,
				positionText
			}
		},
		{
			layout = wibox.layout.stack,
			progress,
			{
				layout = wibox.container.place,
				halign = 'center',
				valign = 'center',
				{
					widget = wibox.container.margin,
					top = 2, bottom = 2, left = 2, right = 2,
					slider
				}
			}
		}
	}
	info:ajust_ratio(2, 0.45, 0.15, 0.4)
	info:ajust_ratio(3, 0.85, 0.15, 0)

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		base.sideDecor {
			h = 180,
			bg = bgcolor
		},
		{
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, true, false, false, base.rad) end,
			bg = bgcolor,
			widget = wibox.container.background,
			forced_width = musicDisplay.width - (base.width * 2),
			forced_height = musicDisplay.height,
			{
				widget = wibox.container.margin,
				top = 20, left = 20 - (base.widths.empty + base.widths.round), right = 20, bottom = 20,
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = 18,
					{
						widget = wibox.container.constraint,
						width = 140,
						albumArt
					},
					info
				}
			}
		}
	}
	musicDisplay:setup {
		layout = wibox.container.place,
		realWidget
	}

	widgets.musicDisplay = {}
	function widgets.musicDisplay.toggle()
		if not musicDisplay.visible then
			awful.placement.under_mouse(musicDisplay)
		end
		musicDisplay.visible = not musicDisplay.visible -- invert
	end
end

do
	local volSliderBack = wibox.widget {
		widget = wibox.widget.progressbar,
		border_color = beautiful.fg_sec,
		border_width = 1,
		forced_height = 18,
		paddings = 4,
		background_color = beautiful.bg_normal,
		max_value = 100,
		shape = base.shape,
		bar_shape = base.shape
	}

	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = volSliderBack.forced_height,
		bar_color = '#00000000',
	}

	local function setupSlider()
		volSliderBack.color = string.format('linear:0,0:%s,0:0,%s:%s,%s', math.floor(slider.value), base.gradientColors[1], math.floor(slider.value), base.gradientColors[2])
		volSliderBack.value = slider.value
	end

	vol.get_volume_state(function(volume)
		slider.value = volume
		setupSlider()
	end)

	slider:connect_signal('property::value', function()
		vol.set(slider.value)
		setupSlider()
	end)

	widgets.volslider = wibox.widget {
		layout = wibox.layout.stack,
		volSliderBack,
		{
			layout = wibox.container.place,
			halign = 'center',
			valign = 'center',
			{
				widget = wibox.container.margin,
				top = 2, bottom = 2, left = 2, right = 2,
				slider
			}
		}
	}
end

do
	local control = wibox {
		width = dpi(480),
		height = dpi(180),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		{
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, false, true, base.rad) end,
			bg = beautiful.bg_normal,
			widget = wibox.container.background,
			forced_width = control.width - (base.width * 2),
			forced_height = control.height,
			{
				widget = wibox.container.margin,
				top = 20, left = 20, right = 20, bottom = 20,
				{
					layout = wibox.layout.fixed.vertical,
					spacing = 18,
					widgets.volslider
				}
			}
		},
		base.sideDecor {
			h = 180,
			position = 'right'
		},
	}

	control:setup {
		layout = wibox.container.place,
		realWidget
	}

	widgets.controlCenter = {}
	function widgets.controlCenter.toggle()
		if not control.visible then
			awful.placement.top_right(control, { margins = { top = dpi(beautiful.topbar_height) + beautiful.useless_gap * 2, right = dpi(12) }, parent = s })
		end

		control.visible = not control.visible
	end
end

do
	local powerMenu = wibox {
		width = dpi(520),
		height = dpi(200),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}
	local function hide()
		powerMenu.visible = false
		awful.keygrabber.stop()
	end

	local powerText = wibox.widget {
		widget = wibox.widget.textbox,
		markup = helpers.colorize_text('Power Options Menu', beautiful.fg_sec),
		font = 'SF Pro Display 16'
	}
	local function setupDisplayers(set)
		for i, widget in ipairs(set) do
			if i % 2 ~= 0 then
				widget:connect_signal('mouse::enter', function() powerText.markup = helpers.colorize_text(set[i + 1], beautiful.fg_sec) end)
			end
		end
	end

	local function btn(bc, ic, icf)
		return button(bc, ic, 58, helpers.rrect(base.radius))
	end
	local buttonColor = beautiful.fg_normal
	local logout = btn(buttonColor, 'logout')

	logout:connect_signal('button::press', function()
		awesome.quit()
		hide()
	end)

	local shutdown = btn(buttonColor, 'power2')
	shutdown:connect_signal('button::press', function()
		awful.spawn 'poweroff'
		hide()
	end)
	local restart = btn(buttonColor, 'restart')
	restart:connect_signal('button::press', function()
		awful.spawn 'reboot'
		hide()
	end)
	local sleep = btn(buttonColor, 'sleep')
	sleep:connect_signal('button::press', function()
		awful.spawn 'systemctl suspend'
		hide()
	end)
	setupDisplayers {
		logout,
		'Logout',
		shutdown,
		'Shutdown',
		restart,
		'Restart',
		sleep,
		'Sleep'
	}

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		{
			widget = wibox.container.background,
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, false, false, true, base.rad) end,
			bg = bgcolor,
			forced_width = powerMenu.width - dpi(base.width),
			{
				widget = wibox.container.margin,
				left = dpi(base.width),
				{
					layout = wibox.layout.align.vertical,
					{
						layout = wibox.container.place
					},
					{
						widget = wibox.container.margin,
						top = beautiful.dpi(8), bottom = beautiful.dpi(8),
						{
							layout = wibox.layout.flex.horizontal,
							logout,
							shutdown,
							restart,
							sleep
						}
					},
					{
						widget = wibox.container.margin,
						bottom = 12,
						right = dpi(base.width) / 2,
						{
							layout = wibox.layout.fixed.vertical,
							spacing = 12,
							{
								widget = wibox.widget.separator,
								forced_height = 1,
								thickness = 1,
								orientation = 'horizontal',
								color = beautiful.fg_sec
							},
							{
								layout = wibox.layout.align.horizontal,
								expand = 'none',
								{
									layout = wibox.layout.fixed.horizontal,
									spacing = 8,
									{
										layout = wibox.container.place,
										valign = 'center',
										{
											widget = wibox.container.constraint,
											width = 22,
											w.imgwidget 'grey-logo.png'
										}
									},
									powerText
								},
								--[[
								{
									layout = wibox.container.place
								},
								{
									widget = wibox.widget.textbox,
									markup = helpers.colorize_text(string.format('Goodbye, %s. What would you like to do?', os.getenv 'USER' or user), beautiful.fg_sec)
								}
								]]--
							}
						}
					}
				}
			}
		},
		base.sideDecor {
			h = powerMenu.height,
			position = 'right',
			bg = bgcolor
		},
	}
	realWidget:connect_signal('mouse::leave', function()
		powerText.markup = helpers.colorize_text('Power Options Menu', beautiful.fg_sec)
	end)

	powerMenu:setup {
		layout = wibox.container.place,
		realWidget
	}

	widgets.powerMenu = {}
	function widgets.powerMenu.toggle()
		if not powerMenu.visible then
			awful.placement.centered(powerMenu, {parent = awful.screen.focused()})
			awful.keygrabber.run(function(_, _, event)
				if event == 'release' then return end
				hide()
			end)
		end

		powerMenu.visible = not powerMenu.visible
	end
end

do
	local startMenu = wibox {
		height = dpi(580),
		width = dpi(460),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}
	helpers.hideOnClick(startMenu)

	local result = {}
	local allApps = {}
	local appList = wibox.layout.overflow.vertical()
	appList.spacing = 1
	appList.step = 25
	appList.scrollbar_widget = {
		{
			widget = wibox.widget.separator,
			shape = gears.shape.rounded_bar,
			color = beautiful.xcolor11
		},
		widget = wibox.container.margin,
		left = dpi(5),
	}
	appList.scrollbar_width = dpi(14)

	menugen.generate(function(entries)
		-- Add category icons
		for k, v in pairs(menugen.all_categories) do
			table.insert(result, { k, {}, v.icon })
		end

		-- Get items table
		for k, v in pairs(entries) do
			for _, cat in pairs(result) do
				if cat[1] == v.category then
					table.insert(cat[2], {v.name, v.cmdline, v.icon})
					allApps[v.name] = {v.cmdline, v.icon}
					break
				end
			end
		end

		local function pairsByKeys (t, f)
			local a = {}
			for n in pairs(t) do table.insert(a, n) end
			table.sort(a, f)
			local i = 0      -- iterator variable
			local iter = function ()   -- iterator function
				i = i + 1
				if a[i] == nil then return nil
				else return a[i], t[a[i]]
				end
			end
			return iter
		end

--		for i = #result, 1, -1 do
--			local v = result[i]
--			if #v[2] == 0 then
--				-- Remove unused categories
--				table.remove(result, i)
--			else
--				table.sort(v[2], function(a, b) return string.lower(a[1]) < string.lower(b[1]) end)
--				v[1] = menugen.all_categories[v[1]].name
--			end
--		end

		-- Sort categories alphabetically also
		--table.sort(result, function(a, b) return string.byte(string.lower(a[1])) < string.byte(string.lower(b[1])) end)

		for name, props in pairsByKeys(allApps, function(a, b) return string.lower(a) < string.lower(b) end) do
			local wid = wibox.widget {
				widget = wibox.container.background,
				shape = helpers.rrect(base.radius),
				id = 'bg',
				bg = bgcolor,
				{
					widget = wibox.container.margin,
					margins = dpi(4),
					{	
						layout = wibox.layout.fixed.horizontal,
						spacing = dpi(8),
						{
							{
								widget = wibox.widget.imagebox,
								image = props[2]
							},
							widget = wibox.container.constraint,
							strategy = 'exact',
							width = 32,
							height = 32
						},
						{
							widget = wibox.widget.textbox,
							align = 'center',
							halign = 'center',
							valign = 'center',
							markup = name
						}
					}
				}
			}
			wid.buttons = {
				awful.button({}, 1, function()
					awful.spawn(props[1])
					widgets.startMenu.toggle()
				end)
			}
			helpers.displayClickable(wid, {color = bgcolor})
			appList:add(wid)
		end
	end)

	local power = button(buttonColor, 'power2', beautiful.dpi(18))
	power:connect_signal('button::press', function()
		widgets.powerMenu.toggle()
	end)

	local realWidget = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		{
			widget = wibox.container.background,
			bg = bgcolor,
			forced_width = startMenu.width,
			{
				widget = wibox.container.margin,
				margins = dpi(5),
				{
					layout = wibox.layout.align.vertical,
					{
						widget = wibox.widget.textbox,
						markup = helpers.colorize_text('Applications', beautiful.fg_normal),
						font = beautiful.font:gsub('%d+$', '24')
					},
					{
						widget = wibox.container.margin,
						bottom = dpi(5),
						appList
					},
					{
						layout = wibox.layout.align.horizontal,
						expand = 'none',
						{
							layout = wibox.layout.fixed.horizontal,
							spacing = dpi(5),
							{
								w.imgwidget('avatar.jpg', {
									clip_shape = gears.shape.circle
								}),
								widget = wibox.container.constraint,
								strategy = 'exact',
								width = 24,
								height = 24
							},
							{
								widget = wibox.widget.textbox,
								text = os.getenv 'USER'
							}
						},
						{
							layout = wibox.layout.fixed.horizontal,
						},
						power
					}
				}
			}
		},
	}

	startMenu:setup {
		layout = wibox.layout.stack,
		base.sideDecor {
			h = startMenu.height,
			position = 'top',
			bg = bgcolor,
			emptyLen = base.width / dpi(2)
		},
		{
			widget = wibox.container.margin,
			top = base.width / dpi(2),
			realWidget,
		}
	}

	local scr = awful.screen.focused()
	local animator = rubato.timed {
		outro = 0.5,
		duration = 0.7,
		rate = 30,
		subscribed = function(y)
			startMenu.y = y
		end,
		pos = scr.geometry.height + startMenu.height,
		easing = rubato.quadratic
	}

	
	awful.placement.bottom_left(startMenu, {
		margins = {
			left = beautiful.useless_gap * dpi(2),
			bottom = settings.noAnimate and beautiful.wibar_height + beautiful.useless_gap * dpi(2) or -startMenu.height
		},
		parent = awful.screen.focused()
	})
	if not settings.noAnimate then startMenu.visible = true end

	widgets.startMenu = {}
	function widgets.startMenu.toggle()
		appList.scroll_factor = 0
		if settings.noAnimate then
			startMenu.visible = not startMenu.visible
		else
			if startMenu.y <= scr.geometry.height - startMenu.height then
				animator.target = scr.geometry.height
			else
				animator.target = scr.geometry.height - (beautiful.wibar_height + beautiful.useless_gap * dpi(2)) - startMenu.height
			end
		end
	end
end

widgets.actionCenter = require 'ui.widgets.syntax.actionCenter'

return widgets
