local naughty = require 'naughty'
local categoryMappings = {
	['drive-removable-media'] = 'usb',
	['system.warning'] = 'warning'
}

local M = {
	all = {},
	keepNum = 20
}

naughty.connect_signal('added', function(n)
	print(#M.all, M.keepNum, M.all[#M.all])
	if #M.all > M.keepNum then
		M.all[M.keepNum + 1] = nil
	end
	table.insert(M.all, 1, n)
end)

local function categoryToIcon(cat)
	local mapping = categoryMappings[cat]
	return mapping or cat
end

function M.category(n)
	local category = categoryToIcon(n.category)
	if n.app_icon then
		if not n.app_icon:match 'file://' and not n.app_icon:match '^/' then
			category = categoryToIcon(n.app_icon)
		end
	end

	return category
end

-- Gets the icon of the notification (the small image).
function M.icon(n)
	if not n.app_icon then return end

	if n.app_icon:match 'file://' or n.app_icon:match '^/' then
		return n.app_icon:gsub('file://', '')
	end
end

function M.clearAll()
	M.all = {}
end

return M
