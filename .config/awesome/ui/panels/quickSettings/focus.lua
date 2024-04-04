local M = {}

-- @return boolean state of the setting (on or off)
function M.toggle()
	return false
end

function M.enabled()
	return false
end

function M.status()
	return false, 'Focus'
end

return M
