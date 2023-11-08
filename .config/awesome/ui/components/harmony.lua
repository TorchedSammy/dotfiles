local beautiful = require 'beautiful'
local widgets = require 'ui.widgets'
local wibox = require 'wibox'

local M = {}

function M.titlebar(title, opts)
	opts = opts or {}
	local titleHeight = beautiful.dpi(48)

	local titleText = widgets.coloredText(title, beautiful.fg_normal)
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
				left = beautiful.dpi(16),
				{
					layout = wibox.layout.fixed.horizontal,
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
return M
