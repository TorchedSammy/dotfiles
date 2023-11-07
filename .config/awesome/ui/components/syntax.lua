local base = require 'ui.extras.syntax.base'
local beautiful = require 'beautiful'
local gears = require 'gears'
local rubato = require 'libs.rubato'
local wibox = require 'wibox'
local widgets = require 'ui.widgets'
local M = {}

function M.slider(opts)
	opts = opts or {}

	local progressShape = gears.shape.rounded_bar
	local progress = wibox.widget {
		widget = wibox.widget.progressbar,
		shape = progressShape,
		bar_shape = progressShape,
		background_color = '#00000000',
		max_value = opts.max or 100,
		forced_height = opts.height or beautiful.dpi(10),
		forced_width = opts.width or beautiful.dpi(10),
		id = 'progress'
	}

	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = progress.forced_height,
		forced_width = progress.forced_width,
		bar_color = opts.bg or beautiful.bg_sec,
		bar_shape = progressShape,
		handle_shape = progressShape,
		id = 'slider'
	}

	local function setupProgressColor(pos, length)
		local posFraction = (pos / length)
		local progressLength = opts.width
		local progressCur = posFraction * progressLength
		if progress.muted then
			progress.color = opts.mutedColor or beautiful.fg_tert
		else
			if opts.color and type(opts.color) == 'string' then
				progress.color = opts.color
				return
			end

			progress.color = string.format('linear:0,0:%s,0:0,%s:%s,%s', math.floor(beautiful.dpi(progressCur)), (opts.color or base.gradientColors)[1], math.floor(beautiful.dpi(progressLength)), (opts.color or base.gradientColors)[2])
		end
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

	local icon = opts.icon and widgets.icon(opts.icon, {size = opts.iconSize --[[or beautiful.dpi(32)]]}) or nil

	local wid = wibox.widget {
		widget = wibox.container.place,
		valign = 'center',
		{
			layout = wibox.layout.fixed.horizontal,
			spacing = beautiful.dpi(8),
			icon,
			{
				layout = wibox.container.place,
				{
					layout = wibox.layout.stack,
					{
						widget = wibox.container.margin,
						--left = 0.5, right = 0.5,
						margins = 0.5,
						slider,
					},
					progress,
				}
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
