local awful = require 'awful'
local beautiful = require 'beautiful'
--local gears = require 'gears'
local wibox = require 'wibox'
local settings = require 'sys.settings'
local util = require 'sys.util'

local bars = settings.getConfig 'bars'

for idx, barSetup in ipairs(bars) do
	local function moduleWidgets(position)
		local widgets = {}
		local moduleList = {
			startMenu = nil, -- TODO
			time = require 'ui.widget.time' -- TODO
		}
		for _, moduleName in ipairs(barSetup.modules[position]) do
			local module = moduleList[moduleName]
			if not module then
				-- TODO: warning notification
				return
			end

			table.insert(widgets, module)
		end

		return {
			layout = wibox.layout.fixed.horizontal,
			spacing = util.dpi(barSetup.modules[position].spacing or 10),
			table.unpack(widgets)
		}
	end

	local function createBarWidget()
		return {
			widget = wibox.container.background,
			bg = beautiful.barBackground,
			--shape = barSetup.shape
			{
				widget = wibox.container.margin,
				margins = util.dpi(8),
				{
					layout = (barSetup.position == 'bottom' or barSetup.position == 'top')
					and wibox.layout.align.horizontal or wibox.layout.align.vertical,
					moduleWidgets 'left',
					moduleWidgets 'center',
					moduleWidgets 'right',
				}
			}
		}
	end

	if barSetup.screen == 'all' then
		awful.screen.connect_for_each_screen(function(s)
			if not s.bar then s.bar = {} end
			s.bar[idx] = awful.wibar {
				screen = s,
				position = barSetup.position,
				height = util.dpi(barSetup.height),
				bg = '#00000000'
			}

			s.bar[idx]:setup(createBarWidget())
		end)
	end
end
