local gears = require 'gears'
local xr = require 'beautiful.xresources'

local M = {}

M.dpi = xr.apply_dpi

function M.rrect(rad)
	return function(c, width, height)
		gears.shape.rounded_rect(c, width, height, rad)
	end
end

function M.colorizeText(text, color)
	return '<span foreground="' .. color ..'">' .. text .. '</span>'
end

function M.findWidgetInWibox(widget, wb)
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

	local w = wb._drawable._widget_hierarchy and find_widget_in_hierarchy(wb._drawable._widget_hierarchy, widget)
	if not w then return 0, 0 end

	local bx, by, width, height = w:get_matrix_to_device():transform_rectangle(0, 0, w:get_size())
	return bx, by, width, height
end

return M
