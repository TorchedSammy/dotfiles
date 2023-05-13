local awful = require 'awful'
local beautiful = require 'beautiful'
local settings = require 'conf.settings'
local naughty = require 'naughty'

-- Picom
if settings.picom then
	awful.spawn.with_shell('picom --config ~/.config/picom/' .. beautiful.picom_conf
	.. '.conf ' .. (beautiful.exp_picom_bknd and '--experimental-backends ' or '')
	.. '-b')
end

local programs = {
	-- 'xmodmap -e "pointer = 3 2 1"',
	'udiskie --tray',
	'gcdemu',
	'pactl load-module module-role-ducking trigger_roles=phone,event'
}

for _, p in ipairs(programs) do
	awful.spawn.easy_async('pgrep ' .. p:match '^%w+', function(output)
		if output == '' then
			awful.spawn.easy_async(p, function() end)
		end
	end)
end

