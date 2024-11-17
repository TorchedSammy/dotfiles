local awful = require 'awful'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local util = require 'sys.util'
local settings = require 'sys.settings'
local rubato = require 'libs.rubato'

local M = {}

-- @tparam[opt={}] table args
-- @tparam[opt] string args.attach Where the panel should be attached (position wise), either mouse, or top_right, bottom_left, etc.
-- @tparam[opt] string args.widget
-- @tparam[opt] string args.bg Color to use for the panel background
-- @tparam[opt] string args.shape Shape of the panel window
-- @tparam[opt] string args.radius Radius for rounded rectangle shape
function M.create(args)
	--local panel = M.wibox(args)
	--panel:setup(args.widget)
	--TODO: handle margins and positions properly for bars on left/right
	local panel = wibox {
		shape = args.shape or util.rrect(args.radius),
		ontop = true,
		visible = false,
		bg = args.bg or beautiful.panelBackground,
		widget = {
			layout = wibox.container.place,
			forced_height = args.height,
			forced_width = args.width,
			args.widget
		},
		height = args.height,
		width = args.width,
		open = false
	}

	panel:struts {
		top = beautiful.useless_gap, bottom = beautiful.useless_gap,
		left = beautiful.useless_gap, right = beautiful.useless_gap,
	}

	function panel:toggle(barIdx)
		local scr = awful.screen.focused()
		local function locateQuadrant(x, y)
			local isTop = y < (scr.geometry.height / 2)
			local isLeft = x < (scr.geometry.width / 2)
			local vertAlign = (isTop and 'top' or 'bottom')
			local horizAlign = (isLeft and 'left' or 'right')

			return vertAlign .. '_' .. horizAlign, vertAlign, horizAlign
		end

		local mc = mouse.coords()
		local alignment, vert = locateQuadrant(mc.x, mc.y)
		awful.placement.align(panel, {
			position = alignment,
			margins = {
				left = beautiful.useless_gap,
				right = beautiful.useless_gap,
			},
			--honor_workarea = true,
			--honor_padding = true
		})

		local buffer = barIdx and scr.bar[barIdx].height or 0
		local hideHeight = scr.geometry.height
		local revealHeight = scr.geometry.height - args.height - beautiful.useless_gap - buffer
		local animator = rubato.timed {
			duration = 0.25,
			rate = 120,
			override_dt = true,
			subscribed = function(y)
				panel.y = y
				if y == hideHeight then
					panel.visible = false
				end
			end,
			pos = not panel.open and hideHeight or revealHeight
		}

		if vert == 'bottom' and panel.open then
			panel.y = hideHeight
		end

		panel.open = not panel.open
		if panel.open then
			animator.target = revealHeight
			panel.visible = true
		else
			animator.target = hideHeight
		end
	end

	return panel
end

function M.wibox(opts)
	local bg = opts.bg

	opts.bg = '#00000000'
	if opts.radius then
		opts.bg = bg
		opts.shape = util.rrect(opts.radius / 1.3)
	end

	local wbx = wibox(opts)
	wbx.popup = opts.popup

	local oldSetup = wbx.setup
	function wbx:setup(wid)
		local setupWidget = wibox.widget {
			widget = wibox.container.background,
			shape = util.rrect(opts.radius),
			forced_height = wbx.height,
			forced_width = wbx.width,
			wid
		}
		oldSetup(wbx, {
			layout = wibox.container.place,
			setupWidget
		})
	end
	return wbx
end

return M
