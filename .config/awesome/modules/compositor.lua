local awful = require 'awful'
local beautiful = require 'beautiful'

local M = {
	running = false,
	awesomeKill = false
}

awful.spawn.easy_async('pgrep picom', function(output)
	if output ~= '' then
		M.running = true
	end
end)

function M.state()
	return M.running
end

function M.on()
	awesome.emit_signal('compositor::on')
	M.pid = awful.spawn.easy_async(string.format('picom --config /home/%s/.config/picom/%s.conf', os.getenv 'USER', beautiful.picom_conf), function()
		awesome.emit_signal('compositor::off')
		if M.awesomeKill then
			return
		end
		M.on()
	end)
	M.running = true

	return true
end

function M.off()
	M.awesomeKill = true
	if not M.pid then
		awful.spawn.easy_async('pkill picom', function() end)
	else
		awful.spawn.easy_async(string.format('kill %d', M.pid), function()
			M.awesomeKill = false
		end)
	end
	M.running = false

	return false
end

function M.toggle(on)
	if not M.running or on then
		return M.on()
	else
		return M.off()
	end
end

awesome.connect_signal('exit', M.off)

return M
