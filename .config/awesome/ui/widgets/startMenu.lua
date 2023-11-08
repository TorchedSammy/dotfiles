local awful = require 'awful'
local base = require 'ui.extras.syntax.base'
local beautiful = require 'beautiful'
local gears = require 'gears'
local harmony = require 'ui.components.harmony'
local helpers = require 'helpers'
local rubato = require 'libs.rubato'
local settings = require 'conf.settings'
local syntax = require 'ui.components.syntax'
local w = require 'ui.widgets'
local wibox = require 'wibox'
local extrautils = require 'libs.extrautils'()

local lgi = require 'lgi'
local Gio = lgi.Gio

local M = {
	height = beautiful.dpi(580),
	width = beautiful.dpi(460)
}
local appList = wibox.widget {
	layout = wibox.layout.overflow.vertical()
}

function M.new(opts)
	opts = opts or {}
	opts.shape = opts.shape or helpers.rrect(6)

	local bgcolor = opts.bg or beautiful.bg_popup

	local function button(color_focus, icon, size, shape)
		return w.button(icon, {bg = bgcolor, shape = shape, size = size})
	end

	local result = {}
	local allApps = {}
	local collision = {}
	function setupAppList()
		appList:reset()
		--appList.spacing = beautiful.dpi(2)
		appList.step = 65
		appList.scrollbar_widget = {
			widget = wibox.widget.separator,
			shape = gears.shape.rounded_bar,
			color = beautiful.accent
		}
		appList.scrollbar_width = beautiful.dpi(10)
	end
	setupAppList()

	local power = button(buttonColor, 'power2', beautiful.dpi(18))
	power:connect_signal('button::press', function()
		widgets.powerMenu.toggle()
	end)

	local wid = {
		widget = wibox.container.background,
		bg = bgcolor,
		forced_width = M.width,
		shape = opts.shape,
		{
			widget = wibox.container.margin,
			--margins = beautiful.dpi(5),
			layout = wibox.layout.align.vertical,
			harmony.titlebar 'Apps',
			{
				widget = wibox.container.margin,
				margins = beautiful.dpi(16),
				appList
			},
		}
	}

	function wid:fetchApps()
		--rsetupAppList()
		local allApps = extrautils.apps.get_all()
		local function pairsByKeys (t, f)
				local a = {}
				for m, n in pairs(t) do table.insert(a, m, n) end
				table.sort(a, f)
				local i = 0
				local iter = function ()
					i = i + 1
					if a[i] == nil then return nil
					else return a[i], t[a[i]]
					end
				end
				return iter
			end


		for app in pairsByKeys(allApps, function(a, b) print(a, b); return string.lower(a.name) < string.lower(b.name) end) do
			local name = app.name
			if collision[name] or not app.show then
				goto continue
			end
			collision[name] = true

			local appWid = wibox.widget {
				widget = wibox.container.margin,
				right = beautiful.dpi(8),
				{
					widget = wibox.container.background,
					shape = helpers.rrect(beautiful.radius or base.radius),
					id = 'bg',
					bg = bgcolor,
					{
						widget = wibox.container.margin,
						margins = beautiful.dpi(8),
						{	
							layout = wibox.layout.fixed.horizontal,
							spacing = beautiful.dpi(8),
							{
								widget = wibox.container.place,
								{
									{
										widget = wibox.widget.imagebox,
										image = app.icon,
										clip_shape = helpers.rrect(2)
									},
									widget = wibox.container.constraint,
									strategy = 'exact',
									width = beautiful.dpi(32),
									height = beautiful.dpi(32),
								}
							},
							{
								widget = wibox.container.place,
								{
									layout = wibox.layout.fixed.vertical,
									{
										widget = wibox.widget.textbox,
										valign = 'center',
										markup = helpers.colorize_text(name, beautiful.fg_normal)
									},
									app.description and {
										layout = wibox.container.place,
										halign = 'left',
										forced_width = beautiful.dpi(360),
										forced_height = beautiful.dpi(22),
										{
											widget = wibox.widget.textbox,
											markup = helpers.colorize_text(app.description or '', beautiful.fg_sec)
										}
									} or nil
								}
							}
						}
					}
				}
			}
			appWid.buttons = {
				awful.button({}, 1, function()
					app.launch()
					opts.menu:toggle()
				end)
			}
			helpers.displayClickable(appWid, {bg = bgcolor})
			appList:add(appWid)

			::continue::
		end
	end

	local monitor = Gio.AppInfoMonitor.get()

	function monitor:on_changed(...)
		wid:fetchApps()
	end
-- ^ doesnt actually work

	wid:fetchApps()

	return wid, opts.width, opts.height
end

function M.bindMethods(startMenu)
	helpers.slidePlacement(startMenu, {
		placement = 'bottom_left',
		toggler = function() appList.scroll_factor = 0 end
	})
end

function M.create(opts)
	opts = opts or {}

	local startMenu = wibox {
		height = beautiful.dpi(580),
		width = beautiful.dpi(460),
		bg = '#00000000',
		shape = gears.shape.rectangle,
		ontop = true,
		visible = false
	}
	opts.menu = startMenu
	local w, width, height = M.new(opts)

	startMenu:setup(w)

	return startMenu
end

return M
