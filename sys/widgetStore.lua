local M = {
	widgets = {}
}

function M.add(name, widget)
	M.widgets[name] = widget
end

function M.get(name)
	return M.widgets[name]
end

return M
