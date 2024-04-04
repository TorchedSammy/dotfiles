local M = {
	currentWidget = nil
}

function M.passthrough(new)
	if M.currentWidget and M.currentWidget ~= new then
		M.currentWidget:off()
	end

	M.currentWidget = new
end

return M
