local beautiful = require 'beautiful'
local widgets = require 'ui.widgets'
local category = {}

local function new(args)
	args = args or {}

	local ico = widgets.icon {
		icon = 'notification',
		color = args.color or 'xcolor14'
	}

	return ico
end

return setmetatable(category, {__call = function(_, ...) return new(...) end})
