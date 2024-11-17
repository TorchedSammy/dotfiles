local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local wibox = require 'wibox'

local lgi = require 'lgi'
local Gio = lgi.Gio

local util = require 'sys.util'
local extrautils = require 'libs.extrautils'()
local titlebar = require 'ui.widget.titlebar'
local panels = require 'ui.panels'
local textbox = require 'ui.widget.textbox'

--local apps = {}
local appList = wibox.widget {
	layout = wibox.layout.overflow.vertical()
}

local function setupAppList()
	-- setting spacing makes it have a wack amount of space
	-- because awesome handles not visible widgets in a layout in a dumb way
	--appList.spacing = util.dpi(1)
	appList.step = util.dpi(100)
	appList.scrollbar_widget = {
		widget = wibox.widget.separator,
		shape = gears.shape.rounded_bar,
		color = beautiful.accent
	}
	appList.scrollbar_width = util.dpi(10)
end

local function fetchApps()
	local collision = {}

	setupAppList()
	local allApps = extrautils.apps.get_all()
	local function pairsByKeys(t, f)
		local a = {}
		for m, n in pairs(t) do
			table.insert(a, m, n)
		end
		table.sort(a, f)
		local i = 0
		local iter = function()
			i = i + 1
			if a[i] == nil then
				return nil
			else
				return a[i], t[a[i]]
			end
		end
		return iter
	end

	for app in pairsByKeys(allApps, function(a, b)
		return string.lower(a.name) < string.lower(b.name)
	end) do
		local name = app.name
		if collision[name] or not app.show then
			goto continue
		end

		collision[name] = true
		--table.insert(apps, app.name)

		local appWid = wibox.widget {
			widget = wibox.container.margin,
			right = util.dpi(8),
			id = app.name,
			{
				widget = wibox.container.background,
				bg = beautiful.popupBackground,
				shape = util.rrect(beautiful.radius),
				id = 'bg',
				{
					widget = wibox.container.margin,
					margins = util.dpi(8),
					{
						layout = wibox.layout.fixed.horizontal,
						spacing = util.dpi(8),
						{
							widget = wibox.container.place,
							{
								{
									widget = wibox.widget.imagebox,
									image = gears.surface.load_uncached_silently(
										app.icon,
										extrautils.apps.lookup_icon 'application-x-executable'
									),
									clip_shape = util.rrect(2)
								},
								widget = wibox.container.constraint,
								strategy = 'exact',
								width = util.dpi(32),
								height = util.dpi(32)
							}
						},
						{
							widget = wibox.container.place,
							{
								layout = wibox.layout.fixed.vertical,
								{
									text = name,
									font = beautiful.fontName .. ' Medium 12',
									widget = wibox.widget.textbox
								},
								app.description and {
									layout = wibox.container.place,
									halign = 'left',
									forced_width = util.dpi(360),
									forced_height = util.dpi(22),
								} or nil
							}
						}
					}
				}
			}
		}

		appWid.buttons = {
			awful.button({}, 1, function()
				--opts.menu:off()
				app.launch()
				--resetSearch()
			end)
		}

		--helpers.displayClickable(appWid, {bg = bgcolor})
		appList:add(appWid)

		::continue::
	end
end

fetchApps()

local startMenu = panels.create {
	widget = {
		layout = wibox.layout.fixed.vertical,
		{
			widget = titlebar,
			title = 'Apps'
		},
		{
			widget = wibox.container.margin,
			margins = util.dpi(16),
			appList
		}
	},
	height = util.dpi(580),
	width = util.dpi(460),
}

return startMenu
