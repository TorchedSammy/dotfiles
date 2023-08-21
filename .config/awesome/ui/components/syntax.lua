local base = require 'ui.extras.syntax.base'
local beautiful = require 'beautiful'
local gears = require 'gears'
local rubato = require 'libs.rubato'
local wibox = require 'wibox'
local M = {}

function M.slider(opts)
	opts = opts or {}

	local progressShape = gears.shape.rounded_bar
	local progress = wibox.widget {
		widget = wibox.widget.progressbar,
		shape = progressShape,
		bar_shape = progressShape,
		background_color = opts.bg or beautiful.bg_sec,
		max_value = opts.max or 100,
		forced_height = opts.height or beautiful.dpi(10),
		forced_width = opts.width or beautiful.dpi(10),
		id = 'progress'
	}

	local function setupProgressColor(pos, length)
		local posFraction = (pos / length)
		local progressLength = opts.width
		local progressCur = posFraction * progressLength
		progress.color = string.format('linear:0,0:%s,0:0,%s:%s,%s', math.floor(beautiful.dpi(progressCur)), base.gradientColors[1], math.floor(beautiful.dpi(progressLength)), base.gradientColors[2])
		progress.value = pos
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

	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = progress.forced_height,
		bar_color = '#00000000',
		id = 'slider'
	}

	slider:connect_signal('property::value', function()
		progressAnimator.target = slider.value
		if opts.onChange then opts.onChange(slider.value) end
	end)

	local wid = wibox.widget {
		layout = wibox.layout.fixed.horizontal,
		spacing = beautiful.dpi(8),
		opts.icon and w.icon(opts.icon, {size = opts.iconSize --[[or beautiful.dpi(32)]]}) or nil,
		{
			layout = wibox.layout.stack,
			progress,
			slider
		}
	}

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
				progress.color = v
			elseif k == 'max' then
				progress.max_value = v
				slider.maximum = v
			end
		end
	})
end

return M
