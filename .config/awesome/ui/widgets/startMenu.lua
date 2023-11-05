local awful = require 'awful'
local base = require 'ui.extras.syntax.base'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local rubato = require 'libs.rubato'
local settings = require 'conf.settings'
local syntax = require 'ui.components.syntax'
local w = require 'ui.widgets'
local wibox = require 'wibox'
local extrautils = require 'modules.extrautils'()

local lgi = require 'lgi'
local Gio = lgi.Gio

local bgcolor = beautiful.bg_sec
local function button(color_focus, icon, size, shape)
	return w.button(icon, {bg = bgcolor, shape = shape, size = size})
end

local M = {
	height = beautiful.dpi(580),
	width = beautiful.dpi(460)
}
local appList = wibox.layout.overflow.vertical()

function M.new(opts)
	opts = opts or {}
	opts.shape = opts.shape or helpers.rrect(6)

	local bgcolor = opts.bg

	local result = {}
	local allApps = {}
	local collision = {}
	appList.spacing = 1
	appList.step = 65
	appList.scrollbar_widget = {
		{
			widget = wibox.widget.separator,
			shape = gears.shape.rounded_bar,
			color = beautiful.xcolor11
		},
		widget = wibox.container.margin,
		left = beautiful.dpi(5),
	}
	appList.scrollbar_width = beautiful.dpi(14)

	local power = button(buttonColor, 'power2', beautiful.dpi(18))
	power:connect_signal('button::press', function()
		widgets.powerMenu.toggle()
	end)

	local w = {
		widget = wibox.container.background,
		bg = bgcolor,
		forced_width = M.width,
		shape = opts.shape,
		{
			widget = wibox.container.margin,
			--margins = beautiful.dpi(5),
			layout = wibox.layout.align.vertical,
			{
				widget = wibox.widget.textbox,
				markup = helpers.colorize_text('Applications', beautiful.fg_normal),
				font = beautiful.font:gsub('%d+$', '24')
			},
			{
				widget = wibox.container.margin,
				bottom = beautiful.dpi(5),
				appList
			},
			{
				layout = wibox.layout.align.horizontal,
				expand = 'none',
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.dpi(5),
					{
						w.imgwidget('avatar.jpg', {
							clip_shape = gears.shape.circle
						}),
						widget = wibox.container.constraint,
						strategy = 'exact',
						width = 24,
						height = 24
					},
					{
						widget = wibox.widget.textbox,
						text = os.getenv 'USER'
					}
				},
				{
					layout = wibox.layout.fixed.horizontal,
				},
				power
			}
		}
	}

	function w:fetchApps()
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

			local wid = wibox.widget {
				widget = wibox.container.background,
				shape = helpers.rrect(base.radius),
				id = 'bg',
				bg = bgcolor,
				{
					widget = wibox.container.margin,
					margins = beautiful.dpi(4),
					{	
						layout = wibox.layout.fixed.horizontal,
						spacing = beautiful.dpi(8),
						{
							{
								widget = wibox.widget.imagebox,
								image = app.icon
							},
							widget = wibox.container.constraint,
							strategy = 'exact',
							width = 32,
							height = 32
						},
						{
							widget = wibox.widget.textbox,
							align = 'center',
							halign = 'center',
							valign = 'center',
							markup = name
						}
					}
				}
			}
			wid.buttons = {
				awful.button({}, 1, function()
					app.launch()
					opts.menu:toggle()
				end)
			}
			helpers.displayClickable(wid, {bg = bgcolor})
			appList:add(wid)

			::continue::
		end
	end

--[[
	local monitor = Gio.AppInfoMonitor.get()

	function monitor:on_changed(...)
		w:fetchApps()
	end
]]--
-- ^ doesnt actually work

	w:fetchApps()

	return w, opts.width, opts.height
end

function M.bindMethods(startMenu)
	local scr = awful.screen.focused()
	local startMenuOpen = false
	local animator = rubato.timed {
		duration = 0.3,
		rate = 60,
		subscribed = function(y)
			startMenu.y = y
		end,
		pos = scr.geometry.height,
		easing = rubato.linear
	}

	local function doPlacement()
		awful.placement.bottom_left(startMenu, {
			margins = {
				left = beautiful.useless_gap * beautiful.dpi(2),
				bottom = settings.noAnimate and beautiful.wibar_height + beautiful.useless_gap * beautiful.dpi(2) or -startMenu.height
			},
			parent = awful.screen.focused()
		})
	end
	doPlacement()
	if not settings.noAnimate then startMenu.visible = true end

	if settings.noAnimate then
		helpers.hideOnClick(startMenu)
	else
		helpers.hideOnClick(startMenu, settings.noAnimate and nil or function()
			if startMenuOpen then
				startMenu:toggle()
			end
		end)
	end

	function startMenu:toggle()
		appList.scroll_factor = 0
		if not startMenuOpen then
			doPlacement()
		end

		if settings.noAnimate then
			startMenu.visible = not startMenu.visible
		else
			if startMenuOpen then
				animator.target = scr.geometry.height
			else
				animator.target = scr.geometry.height - (beautiful.wibar_height + beautiful.useless_gap * beautiful.dpi(2)) - startMenu.height
			end
		end
		startMenuOpen = not startMenuOpen
	end
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

	startMenu:setup {
		layout = wibox.layout.stack,
		base.sideDecor {
			h = startMenu.height,
			position = 'top',
			bg = bgcolor,
			emptyLen = base.width / beautiful.dpi(2)
		},
		{
			widget = wibox.container.margin,
			top = base.width / beautiful.dpi(2),
			w
		}
	}

	return startMenu
end

return M
