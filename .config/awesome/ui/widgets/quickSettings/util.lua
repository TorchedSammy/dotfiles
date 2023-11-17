local M = {}

function M.emitSignal(qsName, name, ...)
	awesome.emit_signal(string.format('quicksettings.%s::%s', qsName, name), ...)
end

function M.connectSignal(qsName, name, callback)
	awesome.connect_signal(string.format('quicksettings.%s::%s', qsName, name), callback)
end

return M
