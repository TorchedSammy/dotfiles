local awful = require 'awful'
local beautiful = require 'beautiful'
local helpers = require 'helpers'

local button = require 'ui.widgets.button'
local wibox = require 'wibox'

-- Systray
local function find_widget_in_wibox(wb, widget)
	local function find_widget_in_hierarchy(h, widget)
		if h:get_widget() == widget then
		return h
		end
		local result
		for _, ch in ipairs(h:get_children()) do
		result = result or find_widget_in_hierarchy(ch, widget)
		end
		return result
	end
	local h = wb._drawable._widget_hierarchy
	return h and find_widget_in_hierarchy(h, widget)
end

return function(opts)
	local systray_margin = (beautiful.wibar_height - beautiful.systray_icon_size) / 3
	local actualSystray = wibox.widget.systray()
	actualSystray:set_base_size(beautiful.systray_icon_size)

	local popup
	local btn
	local wid

	local function adjustSystray()
		local w = find_widget_in_wibox(opts.bar, wid)
		if not w then return 0, 0 end

		local bx, by, width, height = w:get_matrix_to_device():transform_rectangle(0, 0, w:get_size())

		local x = opts.vertical
			and bx + width + beautiful.useless_gap
			or bx + (width / 2) - (((beautiful.systray_icon_size * awesome.systray()) + (beautiful.systray_icon_spacing * (awesome.systray() - 1))) / 2) - systray_margin
		local y = opts.vertical
			and by + height + beautiful.useless_gap
			or screen.primary.geometry.height - height - beautiful.wibar_height - (beautiful.useless_gap * 2) - (opts.margin and opts.margin or 0)

		return x, y
	end

	local function setPopupPos(px, py)
		popup.x = px
		--popup.y = py
	end

	actualSystray:connect_signal('widget::layout_changed', function()
		setPopupPos(adjustSystray())
	end)

	btn = button {
		icon = 'expand-more',
		bg = opts.bg,
		onClick = function()
			if awesome.systray() ~= 0 then
				--setPopupPos(adjustSystray())
				
				popup:toggle()
			end
		end
	}
	--[[
	local oldDraw = btn.draw
	function btn:draw()
	end
	]]--

	local systrayPopup = wibox.widget {
		actualSystray,
		margins = systray_margin,
		widget = wibox.container.margin
	}

	popup = awful.popup {
		widget = systrayPopup,
		shape = helpers.rrect(6),
		ontop = true,
		visible = false,
		bg = beautiful.bg_popup
		--[[
		placement = function(w)
			awful.placement.bottom_right(w, {
				margins = {
					bottom = beautiful.dpi(beautiful.wibar_height) + beautiful.useless_gap, right = beautiful.dpi(32)
				},
				parent = awful.screen.focused()
			})
		end
		]]--
	}
	awesome.connect_signal('makeup::put_on', function()
		popup.bg = beautiful.bg_popup
	end)
	--popup:move_next_to(btn)

	if opts.vertical then
		wid = wibox.widget {
			widget = wibox.container.rotate,
			direction = 'west',
			btn
		}
	else
		wid = btn
	end

	helpers.slidePlacement(popup, {
		placement = 'bottom_right',
		toggler = function(state)
			btn.icon = state and 'expand-less' or 'expand-more'
		end,
		hoffset = systray_margin * 3,
		coords = function()
			local x = adjustSystray()

			return {x = x}
		end
	})

	return wid, popup
end
