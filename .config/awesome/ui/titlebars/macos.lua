-- macos style titlebar
local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local wibox = require 'wibox'

client.connect_signal('request::titlebars', function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal('request::activate', 'titlebar', {raise = true})
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal('request::activate', 'titlebar', {raise = true})
			awful.mouse.client.resize(c)
		end)
	)
	function titlebarbtn(char, color, func)
		return wibox.widget {
			{
				{
					markup = helpers.colorize_text(char, color),
					widget = wibox.widget.textbox,
				},
				top = 4, bottom = 4, 
				widget = wibox.container.margin
			},
			bg = color,
			widget = wibox.container.background,
			buttons = gears.table.join(awful.button({}, 1, func)),
			shape = gears.shape.circle
		}
	end

	local minimize = titlebarbtn('', beautiful.xcolor3, function()
		c.minimized = true
		awful.client.next(1)
        if client.focus then
            client.focus:raise()
        end
	end)
	local maximize = titlebarbtn('', beautiful.xcolor2, function()
        helpers.maximize(c)
	end)
	local close = titlebarbtn('', beautiful.xcolor1, function()
		c:kill()
	end)

	awful.titlebar(c): setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			buttons = buttons,
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			buttons = buttons,
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		},
		{
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.wibar_spacing,
				minimize,
				maximize,
				close
			},
			left = beautiful.wibar_spacing,
			right = beautiful.wibar_spacing,
			widget = wibox.container.margin,
		}
	}
end)

