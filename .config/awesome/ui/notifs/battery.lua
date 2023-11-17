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

local function checkPercent(percent)
	if battery.status() ~= 'Charging' then
		if percent < 20 and (not lowNotified or not criticalNotified) then
			battery.setProfile 'powerSave'
		end

		if percent < 20 and percent > 10 and not lowNotified then
			naughty.notification {
				title = 'Battery Low',
				text = string.format('Battery\'s at %d%%. You should consider charging.', percent)
			}
			lowNotified = true
		end
		if percent < 10 and not criticalNotified then
			naughty.notification {
				title = 'Critical Battery Level',
				text = string.format('You should charge now, battery is at %d%%.', percent)
			}
			criticalNotified = true
		end
	end
end

checkPercent(battery.percentage())
awesome.connect_signal('battery::percentage', function(percent)
	checkPercent(percent)
end)
