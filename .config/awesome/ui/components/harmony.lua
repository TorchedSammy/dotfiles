local beautiful = require 'beautiful'
local widgets = require 'ui.widgets'
local wibox = require 'wibox'
local gears = require 'gears'
local rubato = require 'libs.rubato'
local helpers = require 'helpers'

local M = {}

function M.titlebar(title, opts)
	opts = opts or {}
	local titleHeight = beautiful.titlebar_height

	local titleText = wibox.widget {
		text = title,
		font = beautiful.fontName .. ' Bold 12',
		widget = wibox.widget.textbox
	}

	local w = wibox.widget {
		widget = wibox.container.constraint,
		strategy = 'exact',
		height = titleHeight,
		{
			widget = wibox.container.background,
			bg = beautiful.bg_sec,
			id = 'bg',
			{
				widget = wibox.container.margin,
				top = beautiful.dpi(4), bottom = beautiful.dpi(4),
				left = beautiful.dpi(16), right = beautiful.dpi(16),
				{
					layout = wibox.layout.align.horizontal,
					spacing = beautiful.dpi(8),
					opts.before,
					titleText,
					opts.after
				}
			}
		}
	}

	function w:text(t)
		titleText.text = t
	end

	return w, titleHeight
end

function M.slider(opts)
	opts = opts or {}
	opts.color = opts.color or beautiful.accent

	local progressShape = helpers.rrect(beautiful.radius)
	local progress = wibox.widget {
		widget = wibox.widget.progressbar,
		shape = progressShape,
		bar_shape = progressShape,
		background_color = '#00000000',
		max_value = opts.max or 100,
		forced_height = opts.height or beautiful.dpi(36),
		--forced_width = opts.width or beautiful.dpi(36),
		id = 'progress'
	}

	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = progress.forced_height,
		forced_width = progress.forced_width,
		bar_color = opts.bg or beautiful.xcolor10,
		bar_shape = progressShape,
		handle_color = '#00000000',
		id = 'slider'
	}

	local function setupProgressColor(pos, length)
		local posFraction = (pos / length)
		local progressLength = opts.width
		if progress.muted then
			progress.color = opts.mutedColor or beautiful.fg_tert
		else
			if opts.color and type(opts.color) == 'string' then
				progress.color = opts.color
				goto cont
			end

			progress.color = {
				type  = "linear",
				from  = {0, 0},
				to = {100, 0},
				stops = {
					{0, opts.color[1]},
					{1, opts.color[2]},
				}
			}
		end
		::cont::
		progress._private.value = pos
	end

	local progressAnimator = rubato.timed {
		duration = 0.3,
		rate = 60,
		subscribed = function(pos)
			setupProgressColor(pos, progress.max_value)
		end,
		pos = 0,
		easing = rubato.quadratic
	}

	slider:connect_signal('property::value', function()
		progressAnimator.target = slider.value
		if opts.onChange then opts.onChange(slider.value) end
	end)

	local icon = opts.icon and widgets.icon(opts.icon, {
		size = opts.iconSize or beautiful.dpi(26),
		color = beautiful.bg_normal
	}) or nil

	local wid = wibox.widget {
		layout = wibox.layout.stack,
		{
			widget = wibox.container.margin,
			--left = 0.5, right = 0.5,
			--margins = 0.5,
			slider,
		},
		progress,
		{
			widget = wibox.container.margin,
			left = beautiful.dpi(12),
			top = beautiful.dpi(4),
			bottom = beautiful.dpi(4),
			{
				layout = wibox.container.place,
				halign = 'left',
				icon
			}
		}
	}
	slider:emit_signal 'widget::redraw_needed'

--[[
	return wibox.widget{
		layout = wibox.layout.stack,
		progress,
		slider
	}
	]]

	return setmetatable({}, {
		__index = function(_, k)
			return wid[k]
		end,
		__newindex = function(_, k, v)
			if k == 'value' then
				progressAnimator.target = v
			elseif k == 'color' then
				opts.color = v
				progress.color = v
			elseif k == 'max' then
				progress.max_value = v
				slider.maximum = v
			elseif k == 'icon' then
				icon.icon = v
			elseif k == 'muted' then
				progress.muted = v
				setupProgressColor(progress.value, progress.max_value)
			end
		end
	})
end

return M
