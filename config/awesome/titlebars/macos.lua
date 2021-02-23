local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local helpers = require('helpers')
local beautiful = require('beautiful')

client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({ }, 1, function()
			c:emit_signal("request::activate", "titlebar", {raise = true})
			awful.mouse.client.move(c)
		end),
		awful.button({ }, 3, function()
			c:emit_signal("request::activate", "titlebar", {raise = true})
			awful.mouse.client.resize(c)
		end)
	)
	function titlebarbtn(char, color, func)
		return wibox.widget{
			{
				{
					markup = helpers.colorize_text(char, color),
					--font = "Typicons 17",
					widget = wibox.widget.textbox
				},
				top = 4, bottom = 4, 
				widget = wibox.container.margin
			},
			widget = wibox.container.background,
			buttons = gears.table.join(
				awful.button({}, 1, func))
		}
	end

	local close = titlebarbtn("⬤", beautiful.xcolor1, function ()
		local fc = client.focus
		if fc then fc:kill() end
	end)
	local minimize = titlebarbtn("⬤", beautiful.xcolor3, function ()
		local fc = client.focus
		if fc then fc:kill() end
	end)
	local maximize = titlebarbtn("⬤", beautiful.xcolor2, function ()
		local fc = client.focus
		if fc then fc:kill() end
	end)

	awful.titlebar(c) : setup {
		layout = wibox.layout.align.horizontal,
		expand = "none",
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
			layout = wibox.layout.fixed.horizontal,
			spacing = beautiful.wibar_spacing
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
