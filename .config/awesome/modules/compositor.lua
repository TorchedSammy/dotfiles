local awful = require 'awful'
local beautiful = require 'beautiful'

local M = {
	running = false
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
	awful.spawn.easy_async(string.format('picom -b --config /home/%s/.config/picom/%s.conf', os.getenv 'USER', beautiful.picom_conf), function() end)
	M.running = true
end

function M.off()
	awful.spawn.easy_async('pkill picom', function() end)
	M.running = false
end

function M.toggle(on)
	if not M.running or on then
		M.on()
	else
		M.off()
	end
	return M.running
end

return M
