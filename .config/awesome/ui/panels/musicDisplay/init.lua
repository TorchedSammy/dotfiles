local awful = require 'awful'
local beautiful = require 'beautiful'
local bling = require 'libs.bling'
local gears = require 'gears'
local helpers = require 'helpers'
local makeup = require 'ui.makeup'
local pctl = require 'modules.playerctl'
local rubato = require 'libs.rubato'
local syntax = require 'ui.components.syntax'
local w = require 'ui.widgets'
local wibox = require 'wibox'
local playerctl = bling.signal.playerctl.lib()

local M = {
	width = beautiful.dpi(480),
	height = beautiful.dpi(180)
}

local function coloredText(text, color)
	local wid = wibox.widget {
		widget = wibox.widget.textbox,
		markup = helpers.colorize_text(text, color)
	}
	wid.color = color
	wid.text = text

	function wid.set(key, value)
		wid[key] = value
		wid:set_markup_silently(helpers.colorize_text(wid.text, wid.color))
	end

	return wid
end

function M.new(opts)
	opts = opts or {}
	
	opts.shape = opts.shape or helpers.rrect(6)
	opts.width = opts.width or M.width
	opts.height = opts.height or M.height
	opts.sliderBg = opts.sliderBg or beautiful.xcolor9
	opts.sliderColor = opts.sliderColor or 'accent'

	local bgcolor = opts.bg
	local horizMargin = beautiful.dpi(20)
	local vertMargin = beautiful.dpi(20)

	local albumArt = w.imgwidget('albumPlaceholder.png', {
		clip_shape = helpers.rrect(beautiful.radius / 2)
	})

	local musicArtist = coloredText('Artist', opts.fg or beautiful.fg_normal)
	local musicTitle = coloredText('Title', opts.fg or beautiful.fg_normal)
	local musicAlbum = coloredText('Album', opts.fg_sec or beautiful.fg_sec)
	local positionText = coloredText('0:00', opts.fg_sec or beautiful.fg_sec)

	local position = 0
	local musicDisplay = wibox {
		width = beautiful.dpi(480),
		height = beautiful.dpi(180),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}
	helpers.hideOnClick(musicDisplay)

	local progress = syntax.slider {
		width = 282,
		bg = opts.sliderBg,
		color = opts.sliderColor,
		onChange = function(val)
			playerctl:set_position(val)
		end,
		parentWibox = opts.panel
	}

	local function scroll(widget)
		return wibox.widget {
			layout = wibox.container.scroll.horizontal,
			step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
			max_size = 50,
			speed = 80,
			fps = 60,
			widget
		}
	end

	local wrappedMusicArtist = scroll(musicArtist)
	local wrappedMusicTitle = scroll(musicTitle)
	local wrappedMusicAlbum = scroll(musicAlbum)
	local btnSize = beautiful.dpi(19)

	local updateShuffle
	local shuffleState
	local shuffleActive = 'accent'
	local shuffleInactive = 'fg_normal'
	local shuffle = w.button {
		icon = 'shuffle',
		bg = bgcolor,
		size = btnSize,
		onClick = function()
			shuffleState = not shuffleState
			playerctl:set_shuffle(shuffleState)
			updateShuffle(true)
		end,
		makeup = shuffleInactive
	}
	if shuffleState then
		shuffle.color = shuffleInactive
	else
		shuffle.color = shuffleActive
	end
	shuffle.color = shuffleActive

	updateShuffle = function(toggle)
		local shuffleNewColor = not shuffleState and helpers.beautyVar(shuffleInactive) or helpers.beautyVar(shuffleActive)
		helpers.transitionColor {
			old = (toggle and shuffleState) and helpers.beautyVar(shuffleInactive) or helpers.beautyVar(shuffleActive),
			new = shuffleNewColor,
			transformer = function(col) shuffle.color = col end,
			duration = 0.3
		}
		shuffle.makeup = not shuffleState and shuffleInactive or shuffleActive
	end
		
	playerctl:connect_signal('shuffle', function(_, shuff)
		shuffleState = shuff
		updateShuffle()
	end)

	local prev = w.button {
		icon = 'skip-previous',
		bg = bgcolor,
		size = btnSize,
		onClick = function()
			if position >= 5 then
				playerctl:set_position(0)
				position = 0
				progress.value = 0
				return
			end
			playerctl:previous()
		end
	}

	local playPauseIcons = {'play', 'pause'}
	local playPause = w.button {
		icon = playPauseIcons[2],
		bg = bgcolor,
		size = btnSize,
		onClick = function() playerctl:play_pause() end
	}
	local next = w.button {
		icon = 'skip-next',
		bg = bgcolor,
		size = btnSize,
		onClick = function()
			playerctl:next()
			progress.value = 0
		end
	}

	pctl.listenMetadata(function (title, artist, art, album)
		musicArtist.set('text', artist)
		musicTitle.set('text', title)
		musicAlbum.set('text',  album == '' and '~~~' or album)
		positionText.set('text', '0:00')

		albumArt.image = gears.surface.load_uncached_silently(art)
		playPause.icon = playPauseIcons[2]
		progress.value = 0
		position = 0
	end)

	playerctl:connect_signal('position', function (_, pos, length)
		progress.value = pos
		progress.max = length
		position = pos

		local mins = math.floor(pos / 60)
		local secs = math.floor(pos % 60)
		local time = string.format('%01d:%02d', mins, secs)
		positionText.set('text', time)
	end)

	playerctl:connect_signal('playback_status', function(_, playing)
		if not playing then
			playPause.icon = playPauseIcons[1]
		else
			playPause.icon = playPauseIcons[2]
		end
	end)

	local info = wibox.widget {
		layout = wibox.layout.align.vertical,
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
		progress
	}
	--info:ajust_ratio(2, 0.45, 0.15, 0.4)
	--info:ajust_ratio(3, 0.75, 0.25, 0)

	local w = wibox.widget {
		shape = opts.shape,
		widget = makeup.putOn(wibox.container.background, {bg = opts.bg}),
		forced_width = opts.width, -- - (base.width * 2),
		forced_height = opts.height,
		{
			widget = wibox.container.place,
			{
				widget = wibox.container.margin,
				top = vertMargin, bottom = vertMargin,
				left = horizMargin, right = horizMargin,
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.dpi(20),
					{
						widget = wibox.container.constraint,
						--width = 140,
						--strategy = 'exact',
						{
							layout = wibox.container.place,
							valign = 'center',
							halign = 'center',
							albumArt
						}
					},
					info
				}
			}
		}
	}


	function w.setColors(colors)
		if colors.artist then musicArtist.set('color', colors.artist) end
		if colors.title then musicTitle.set('color', colors.title) end
		if colors.album then musicAlbum.set('color', colors.album) end
		if colors.position then positionText.set('color', colors.position) end
		if colors.progress then progress.color = colors.progress end

		if colors.shuffle then
			shuffleActive = colors.shuffle
			updateShuffle()
		end
	end

	return w, opts.width, opts.height
end

function M.create(opts)
	local musicDisplay = wibox {
		width = beautiful.dpi(480),
		height = beautiful.dpi(180),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}
	opts.panel = musicDisplay
	local w, width, height = M.new(opts)

	musicDisplay:setup {
		widget = wibox.container.place,
		w
	}

	function musicDisplay:toggle()
		if not musicDisplay.visible then
			opts.placement(musicDisplay)
		end
		musicDisplay.visible = not musicDisplay.visible -- invert
	end

	return musicDisplay
end

return M
