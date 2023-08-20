local awful = require 'awful'
local beautiful = require 'beautiful'
local base = require 'ui.extras.syntax.base'
local gears = require 'gears'
local helpers = require 'helpers'
local wibox = require 'wibox'
local w = require 'ui.widgets'

local setup = {}

function setup.start()
	local window = wibox {
		width = beautiful.dpi(745),
		height = beautiful.dpi(592),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = true
	}

	local firstWindow = wibox.widget {
		layout = wibox.layout.fixed.vertical,
		{
			widget = wibox.widget.textbox,
			text = 'Welcome to the Syntax setup!'
		}
	}

	window:setup {
		layout = wibox.layout.fixed.horizontal,
		base.sideDecor {
			h = window.height,
			bg = beautiful.bg_sec,
			emptyLen = base.width / beautiful.dpi(2)
		},
		{
			widget = wibox.container.background,
			shape = function(crr, w, h) return gears.shape.partially_rounded_rect(crr, w, h, false, true, false, false, base.rad) end,
			bg = beautiful.bg_sec,
			forced_width = window.width - (beautiful.dpi(base.width) / beautiful.dpi(2)),
			forced_height = window.height,
			{
				widget = wibox.container.margin,
				top = base.width / beautiful.dpi(2),
				bottom = base.width / beautiful.dpi(2),
				right = base.width / beautiful.dpi(2),
				{
					layout = wibox.layout.fixed.vertical,
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.dpi(5),
						{
							widget = wibox.container.constraint,
							strategy = 'exact',
							width = 24,
							w.imgwidget 'grey-logo.png',
						},
						{
							widget = wibox.widget.textbox,
							font = beautiful.font:gsub('%d+$', '18'),
							text = 'Syntax',
							valign = 'center',
							align = 'center'
						},
					},
					{
						widget = wibox.widget.textbox,
						markup = helpers.colorize_text('Installation', beautiful.fg_sec),
						font = 'SF Pro Display 14'
					},
					firstWindow
				}
			}
		}
	}

	awful.placement.centered(window, {parent = awful.screen.focused()})
end

return setup
