local awful = require 'awful'
local beautiful = require 'beautiful'
local bling = require 'libs.bling'
local gears = require 'gears'
local helpers = require 'helpers'
local pctl = require 'modules.playerctl'
local rubato = require 'libs.rubato'
local syntax = require 'ui.components.syntax'
local w = require 'ui.widgets'
local wibox = require 'wibox'
local playerctl = bling.signal.playerctl.lib()

local bgcolor = beautiful.bg_popup or beautiful.bg_normal

local albumArt = wibox.widget {
	widget = wibox.widget.imagebox,
	clip_shape = helpers.rrect(6),
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
	onChange = function(val)
		playerctl:set_position(val)
	end
}

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

local updateShuffle
local shuffleState
local shuffle = w.button('shuffle', {
	bg = bgcolor,
	size = btnSize,
	onClick = function()
		shuffleState = not shuffleState
		playerctl:set_shuffle(shuffleState)
		updateShuffle()
	end
})

updateShuffle = function()
	if shuffleState then
		shuffle.color = beautiful.accent
	else
		shuffle.color = beautiful.fg_normal
	end
end
	
playerctl:connect_signal('shuffle', function(_, shuff)
	shuffleState = shuff
	updateShuffle()
end)

local prev = w.button('skip-previous', {
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
})

local playPauseIcons = {'play', 'pause'}
local playPause = w.button(playPauseIcons[2], {
	bg = bgcolor,
	size = btnSize,
	onClick = function() playerctl:play_pause() end
})
local next = w.button('skip-next', {
	bg = bgcolor,
	size = btnSize,
	onClick = function() playerctl:next() end
})

pctl.listenMetadata(function (title, artist, art, album)
	musicArtist:set_markup_silently(artist)
	wrappedMusicArtist:emit_signal 'widget::redraw_needed'

	musicTitle:set_markup_silently(title)
	wrappedMusicTitle:emit_signal 'widget::redraw_needed'

	musicAlbum:set_markup_silently(helpers.colorize_text(album == '' and '~~~' or album, beautiful.fg_sec))
	wrappedMusicAlbum:emit_signal 'widget::redraw_needed'

	positionText:set_markup_silently(helpers.colorize_text('0:00', beautiful.fg_sec))

	albumArt.image = art
end)

playerctl:connect_signal('position', function (_, pos, length)
	progress.value = pos
	progress.max = length
	position = pos

	local mins = math.floor(pos / 60)
	local secs = math.floor(pos % 60)
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

local M = {
	width = beautiful.dpi(480),
	height = beautiful.dpi(180)
}

function M.new(opts)
	opts = opts or {}
	
	opts.shape = opts.shape or helpers.rrect(6)
	opts.width = opts.width or M.width
	opts.height = opts.height or M.height

	local w = wibox.widget {
		shape = opts.shape,
		bg = opts.bg,
		widget = wibox.container.background,
		forced_width = opts.width, -- - (base.width * 2),
		forced_height = opts.height,
		{
			widget = wibox.container.margin,
			top = 20,
			left = 20,-- - (base.widths.empty + base.widths.round),
			right = 20,
			bottom = 20,
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

	return w, opts.width, opts.height
end

function M.create(opts)
	local w, width, height = M.new(opts)

	local musicDisplay = wibox {
		width = beautiful.dpi(480),
		height = beautiful.dpi(180),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}

	musicDisplay:setup {
		widget = wibox.container.place,
		w
	}

	helpers.hideOnClick(musicDisplay)

	return {
		toggle = function()
			if not musicDisplay.visible then
				opts.placement(musicDisplay)
			end
			musicDisplay.visible = not musicDisplay.visible -- invert
		end
	}
end

return M