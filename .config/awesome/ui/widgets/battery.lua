local awful = require 'awful'
local battery = require 'modules.battery'
local beautiful = require 'beautiful'
local cairo = require 'lgi'.cairo
local gears = require 'gears'
local widget = require 'wibox.widget'

local constraint = require 'wibox.container.constraint'
local place = require 'wibox.container.place'
local stack = require 'wibox.layout.stack'

local imagebox = require 'wibox.widget.imagebox'
local icon = require 'ui.widgets.icon'

local bat = {mt = {}}

local function new(opts)
	local background = icon {icon = 'battery', size = opts.size, color = beautiful.xcolor12}
	local indicator = widget {
		widget = imagebox,
	}

	local wid = widget {
		layout = constraint,
		strategy = 'exact',
		width = opts.size,
		{
			layout = place,
			{
				layout = stack,
				background,
				indicator
			}
		}
	}

	local tt = awful.tooltip {
		objects = {wid},
		preferred_alignments = {'middle'},
		mode = 'outside',
	}

	local function handleBattery()
		local state = battery.status()
		local batIcon = 'battery'
		local color = beautiful.fg_normal

		local time = battery.time()
		if time ~= '' then time = '\n' .. time end
		local text = string.format('%d%% on battery%s', battery.percentage(), time)

		if state == 'Charging' then
			--batIcon = 'battery-charging'
			color = beautiful.xcolor2
		end

		if state == 'Full' then
			text = 'Full'
		end

		tt.text = text
		local batteryImg = gears.color.recolor_image(string.format('%s/images/icons/%s.svg', beautiful.config_path, batIcon), color)
		local img = cairo.ImageSurface.create(cairo.Format.ARGB32, batteryImg:get_width(), batteryImg:get_height())
		local cr = cairo.Context(img)
		cr:rectangle(0, batteryImg:get_height() - (batteryImg:get_height() * (battery.percentage() / 100)), batteryImg:get_width(), (batteryImg:get_height() * (battery.percentage() / 100)))
		cr:clip()
		cr:set_source_surface(batteryImg, 0, 0)
		cr:paint()

		indicator.image = img
	end
	handleBattery()
	awesome.connect_signal('battery::percentage', handleBattery)

	return wid
end

function bat.mt:__call(...)
	return new(...)
end

return setmetatable(bat, bat.mt)
