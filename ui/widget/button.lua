local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'
local util = require 'sys.util'

local icon = require 'ui.widget.icon'

local button = {mt = {}}
local defaults = {
	size = beautiful.dpi(18),
	size_strategy = 'exact'
}

function button:set_icon(name)
	self._private.icon.icon = name
end

for prop in pairs {'text', 'color', 'textColor'} do
	icon['set_' .. prop] = function(self, value)
		self._private.icon[prop] = value
		self._private[prop] = value

		if prop == '' then
			
		end
	end
end

for prop in pairs {'onClick', 'iconColor'} do
	icon['set_' .. prop] = function(self, value)
		self._private[prop] = value
	end
end

local function new(args)
	assert(type(args) == 'table', 'expected button args to be a table')
	args.size = args.size or defaults.size
	local ico = icon(args)
	local text = wibox.widget {
		widget = wibox.widget.textbox,
		--markup = helpers.colorize_text(args.text or '', helpers.beautyVar(args.textColor or args.color or 'fg_normal')),
		markup = util.colorizeText(args.text or '', args.textColor or beautiful.foreground),
		font = args.font or beautiful.font .. ' 14',
		valign = 'center'
	}

	local ret = wibox.widget {
		layout = wibox.widget.constraint,
		--height = args.size,
		strategy = 'exact',
		{
			id = 'bg',
			--widget = makeup.putOn(background, {bg = args.bg}, {wibox = args.parentWibox}),
			widget = wibox.widget.background,
			--shape = args.shape or (args.text and helpers.rrect(6) or gears.shape.circle),
			shape = gears.shape.circle,
			{
				widget = wibox.container.margin,
				margins = args.margin or args.margins or beautiful.dpi(2),
				{
					layout = wibox.container.place,
					halign = args.align or 'center',
					{
						layout = wibox.layout.fixed.horizontal,
						--spacing = beautiful.dpi(4),
						ico,
						text,
					}
				}
			}
		}
	}
	ret.buttons = {
		awful.button({}, 1, function()
			if ret._private.onClick then ret._private.onClick(ret) end
		end),
	}
	--helpers.displayClickable(ret, args)

	ret._private.icon = ico
	ret._private.textbox = text
	ret._private.onClick = args.onClick

	gears.table.crush(ret, button, true)

	return ret
end

function button.mt:__call(...)
	return new(...)
end

return setmetatable(button, button.mt)
