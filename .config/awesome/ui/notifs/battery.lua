local naughty = require 'naughty'
local sfx = require 'modules.sfx'
local battery = require 'modules.battery'
local lowNotified = false
local criticalNotified = false

awesome.connect_signal('battery::status', function(status, battery)
	if status == 'Charging' then
		lowNotified = false
		criticalNotified = false
		sfx.play 'charge'
	end
end)

awesome.connect_signal('battery::percentage', function(percent)
	if battery.status() ~= 'Charging' then
		if percent > 20 and (not lowNotified or not criticalNotified) then
			battery.setProfile 'powerSave'
		end

		if percent < 20 and percent > 10 and not lowNotified then
			naughty.notification {
				title = 'Battery Low',
				text = 'Battery\'s lower than 20%. You should consider charging.'
			}
			lowNotified = true
		end
		if percent < 10 and not criticalNotified then
			naughty.notification {
				title = 'Critical Battery Level',
				text = 'You should charge now, battery is lower than 10%.'
			}
			criticalNotified = true
		end
	end
end)
