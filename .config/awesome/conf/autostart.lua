local awful = require 'awful'
local beautiful = require 'beautiful'
local compositor = require 'modules.compositor'
local settings = require 'conf.settings'
local naughty = require 'naughty'

-- Picom
if settings.picom then
	--[[
	awful.spawn.with_shell('picom --config ~/.config/picom/' .. beautiful.picom_conf
	.. '.conf ' .. (beautiful.exp_picom_bknd and '--experimental-backends ' or '')
	.. '-b')
	]]--
end

local programs = {
	-- 'xmodmap -e "pointer = 3 2 1"',
	'gnome-keyring-daemon',
	'udiskie',
	'gcdemu',
	'pactl load-module module-role-ducking trigger_roles=phone,event',
	'pactl load-module module-bluetooth-discover',
	'pactl load-module module-bluetooth-policy',
	'pactl load-module module-switch-on-connect',
	'libinput-gestures-setup start',
	'tym --daemon',
	'xplugd',
	--'/usr/libexec/polkit-gnome-authentication-agent-1',
	string.format('gsettings set org.gnome.desktop.interface color-scheme prefer-%s', beautiful.dark and 'dark' or 'light')
}

if settings.picom then
	-- toggle
	compositor.on()
else
	--compositor.off()
end

for _, p in ipairs(programs) do
	awful.spawn.easy_async('pgrep ' .. p:match '^%w+', function(output)
		if output == '' then
			awful.spawn.easy_async(p, function() end)
		end
	end)
end

awful.spawn.easy_async_with_shell('wmctrl -m | grep PID', function(out)
	local pid = out:match '%d+'
	awful.spawn.easy_async_with_shell(string.format('test -f /tmp/awesome && printf "y"', pid), function(out2)
		if not out2:match 'y' then
			awful.spawn.easy_async(string.format('touch /tmp/awesome', pid), function() end)
			awful.spawn.easy_async('dex-autostart --environment Awesome --autostart', function() end)
			awful.spawn.easy_async('pw-play .config/awesome/sounds/startup2.wav', function() end)
		end
	end)
end)
