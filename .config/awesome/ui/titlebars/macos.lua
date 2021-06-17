-- macos style titlebar
local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local naughty = require 'naughty'
local helpers = require 'helpers'
local wibox = require 'wibox'

local function titlebarbtn(c, color_focus, color_unfocus, shp)
    local tb =
        wibox.widget {
        	{
        		widget = wibox.widget.textbox
        	},
        forced_width = beautiful.dpi(16),
        forced_height = beautiful.dpi(16),
        bg = color_focus .. 80,
        shape = shp,
        widget = wibox.container.background
    }

    local function update()
        if client.focus == c then
            tb.bg = color_focus
        else
            tb.bg = color_unfocus
        end
    end
    update()

    c:connect_signal("focus", update)
    c:connect_signal("unfocus", update)

    tb:connect_signal(
        "mouse::enter",
        function()
        	local clr = client.focus ~= c and color_focus or color_focus .. 55
            tb.bg = clr
        end
    )
    tb:connect_signal(
        "mouse::leave",
        function()
        	local clr = client.focus == c and color_focus or color_unfocus
            tb.bg = clr
        end
    )

    tb.visible = true
    return tb
end

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

	local close = titlebarbtn(c, beautiful.xcolor1, beautiful.xcolor8 .. 55, gears.shape.circle)
    close:connect_signal(
        "button::press",
        function()
            c:kill()
        end
    )

    local minimize = titlebarbtn(c, beautiful.xcolor3, beautiful.xcolor8 .. 55, gears.shape.circle)

    minimize:connect_signal(
        "button::press",
        function()
			c.minimized = true
        end
    )

    local maximize = titlebarbtn(c, beautiful.xcolor2, beautiful.xcolor8 .. 55, gears.shape.circle)

    maximize:connect_signal(
        "button::press",
        function()
        	helpers.maximize(c)
        end
    )

	awful.titlebar(c): setup {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
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

