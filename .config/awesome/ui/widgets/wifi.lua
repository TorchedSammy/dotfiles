local awful = require 'awful'
local wifi = require 'modules.wifi'

local icon = require 'ui.widgets.icon'
local stack = require 'wibox.layout.stack'

local w = {mt = {}}

local function new(opts)
	local function stateIcon(strength)
		local strengthExt = ''
		if strength then
			if strength < 4 then
				strengthExt = '-strength-' .. tostring(math.max(strength - 1, 1))
			end
		end
		return wifi.enabled and (wifi.activeSSID and 'wifi' .. strengthExt or 'wifi-noap') or 'wifi-off'
	end
	local function stateText()
		return wifi.enabled and (wifi.activeSSID and wifi.activeSSID or 'Not connected') or 'Wi-fi Off'
	end

	local wifiIcon = icon {icon = stateIcon(), size = opts.size}
	local wifiBackgroundIcon = icon {icon = stateIcon(), size = opts.size, color = 'fg_sec'}
	local tt = awful.tooltip {
		objects = {wifiIcon},
		preferred_alignments = {'middle'},
		mode = 'outside',
	}

	local function setState(strength)
		--tt.text = string.format('%d%% volume%s', volume, muted and ' (muted)' or '')
		tt.text = stateText()
		wifiIcon.icon = stateIcon(strength)
		wifiBackgroundIcon.icon = stateIcon()
	end

	setState(wifi.strength(wifi.activeAP))

	awesome.connect_signal('wifi::toggle', function() setState() end)
	awesome.connect_signal('wifi::disconnected', function() setState() end)
	awesome.connect_signal('wifi::activeAP', function() setState() end)
	awesome.connect_signal('wifi::strength', setState)

	return {
		layout = stack,
		wifiBackgroundIcon,
		wifiIcon,
	}
end

function w.mt:__call(...)
	return new(...)
end

return setmetatable(w, w.mt)
