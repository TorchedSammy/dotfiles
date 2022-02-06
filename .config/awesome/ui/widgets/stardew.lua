local awful = require 'awful'
local beautiful = require 'beautiful'
local dpi = beautiful.dpi
local gears = require 'gears'
local helpers = require 'helpers'
local wibox = require 'wibox'
local w = require 'ui.widgets'

local widgets = {}

widgets.stardew_time = function(s)
	local stardew_time = wibox {
		width = dpi(190),
		height = dpi(100),
		bg = '#00000000',
		visible = true,
	}

	local seasonicon = w.imgwidget('stardew/season-winter.png')
	local weathericon = w.imgwidget('stardew/weather-snow.png')
	-- TODO: rotate arrowImg based on time (i cant figure out how to do this)
	--[[
	local arrowImg = gears.surface.load_uncached_silently(beautiful.config_path .. '/images/stardew/dial-arrowbig.png')
	local dialarrow = wibox.widget {
		image = arrowImg,
		halign = 'right',
		valign = 'center',
		widget = wibox.widget.imagebox
	}
	]]--

	--[[
	-- we'll update the icons every hour
	gears.timer {
		timeout = 60 * 60, -- seconds * minutes (1 hour)
		autostart = true,
		call_now = true,
		callback = function()
		end
	}
	]]--

	stardew_time:setup {
		{
			{
				w.imgwidget('stardew/daynightbig.png'),
				--dialarrow,
				layout = wibox.layout.stack
			},
			widget = wibox.container.margin,
			top = dpi(2),
			bottom = dpi(2)
		},
		{
			{
				{
					{
						align = 'center',
						format = '%a. %d',
						font = 'SF Pro Text Medium 16',
						widget = wibox.widget.textclock,
					},
					top = dpi(5),
					widget = wibox.container.margin,
				},
				{
					-- line
					widget = wibox.widget.separator,
					color = beautiful.xforeground,
					forced_height = dpi(2),
					thickness = 2,
				},
				{
					{
						weathericon,
						w.imgwidget('stardew/clocksep.png'),
						seasonicon,
						layout = wibox.layout.fixed.horizontal,
					},
					widget = wibox.container.background,
					forced_height = dpi(33)
				},
				{
					-- line
					widget = wibox.widget.separator,
					color = beautiful.xforeground,
					forced_height = dpi(2),
					thickness = 2,
				},
				{
					align = 'center',
					format = '%-I:%M %P',
					font = 'SF Pro Text Medium 16',
					widget = wibox.widget.textclock,
				},
				layout = wibox.layout.fixed.vertical
			},
			bg = beautiful.wibar_bg,
			shape = helpers.rrect(2),
			shape_border_color = beautiful.border_normal,
			shape_border_width = 4,
			forced_width = stardew_time.width,
			forced_height = stardew_time.height,
			widget = wibox.container.background,
		},
		layout = wibox.layout.fixed.horizontal,
		spacing = -2,
	}

	stardew_time.visible = true
	awful.placement.top_right(stardew_time, { margins = { top = dpi(beautiful.wibar_height + 12), right = dpi(12) }, parent = s })
end

return widgets
