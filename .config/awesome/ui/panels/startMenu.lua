local awful = require 'awful'
local base = require 'ui.extras.syntax.base'
local beautiful = require 'beautiful'
local gears = require 'gears'
local harmony = require 'ui.components.harmony'
local helpers = require 'helpers'
local makeup = require 'ui.makeup'
local rubato = require 'libs.rubato'
local settings = require 'conf.settings'
local syntax = require 'ui.components.syntax'
local w = require 'ui.widgets'
local wibox = require 'wibox'
local widgets = require 'ui.widgets'
local extrautils = require 'libs.extrautils'()
local inputbox = require 'ui.widgets.inputbox'
local fzy = require 'fzy'

local lgi = require 'lgi'
local Gio = lgi.Gio

local M = {
	height = beautiful.dpi(580),
	width = beautiful.dpi(460)
}
local appList = wibox.widget {
	layout = wibox.layout.overflow.vertical()
}

local appWidgets = {}
local apps = {}

local searchInput = inputbox {
	password_mode = false,
	mouse_focus = true,
	fg = beautiful.xcolor14,
	text_hint = 'Search...',
	font = beautiful.fontName .. ' Bold 12'
}

local function setupAppList()
	-- setting spacing makes it have a wack amount of space
	-- because awesome handles not visible widgets in a layout in a dumb way
	--appList.spacing = beautiful.dpi(1)
	appList.step = beautiful.dpi(100)
	appList.scrollbar_widget = {
		widget = wibox.widget.separator,
		shape = gears.shape.rounded_bar,
		color = beautiful.accent
	}
	appList.scrollbar_width = beautiful.dpi(10)
end

awesome.connect_signal('makeup::put_on', function()
	setupAppList()
end)

local function handleSearch()
	local text = searchInput:get_text()
	appList:scroll(-9999)

	local matchIdx = 1
	for idx, appName in ipairs(apps) do
		local wid = appList.children[idx]
		if wid == nil then return end

		if text ~= '' then
			local match = fzy.has_match(searchInput:get_text(), appName)
			if match then
				wid.visible = true
				matchIdx = matchIdx + 1
			else
				wid.visible = false
				appList:emit_signal 'widget::redraw_needed'
			end
		else
			wid.visible = true
			appList:emit_signal 'widget::redraw_needed'
		end
	end
end

local function resetSearch()
	searchInput:unfocus()
	searchInput:set_text('')
	handleSearch()
end

searchInput:connect_signal('inputbox::keypressed', function() handleSearch() end)

function M.new(opts)
	opts = opts or {}
	opts.shape = opts.shape or helpers.rrect(6)
	local bgcolor = opts.bg or 'bg_popup'

	local result = {}
	local allApps = {}
	local collision = {}
	appList:reset()
	setupAppList()

	local wid = {
		widget = wibox.container.margin,
		--margins = beautiful.dpi(5),
		layout = wibox.layout.align.vertical,
		harmony.titlebar('Apps', {parentWibox = opts.menu}),
		{
			widget = wibox.container.margin,
			margins = beautiful.dpi(16),
			{
				layout = wibox.layout.stack,
				{
					layout = wibox.container.place,
					halign = 'right',
					forced_width = beautiful.dpi(10),
					{
						widget = wibox.container.constraint,
						width = beautiful.dpi(10),
						{
							widget = wibox.container.margin,
							bottom = beautiful.dpi(32),
							{
								widget = makeup.putOn(wibox.widget.separator, {color = 'containerLow'}, {wibox = opts.menu}),
								shape = gears.shape.rounded_bar,
							}
						}
					}
				},
				{
					widget = wibox.container.margin,
					bottom = beautiful.dpi(32),
					appList,
				},
				{
					widget = wibox.container.margin,
					right = beautiful.dpi(18),
					{
						widget = makeup.putOn(wibox.container.background, function()
							return {
								bg = {
									type  = "linear",
									from  = {M.width, 0},
									to = {M.width, M.height - beautiful.dpi(16) - beautiful.titlebar_height},
									stops = {
										{0, beautiful.bg_popup .. '00'},
										{0.8, beautiful.bg_popup .. '00'},
										{0.88, beautiful.bg_popup .. 'cc'},
										{0.9, beautiful.bg_popup},
									}
								}
							}
						end, {wibox = opts.menu}),
					},
				},
				{
					widget = wibox.container.margin,
					bottom = beautiful.dpi(8),
					{
						layout = wibox.container.place,
						valign = 'bottom',
						searchInput.widget,
					}
				}
			},
		},
	}

	function wid:fetchApps()
		--setupAppList()
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


		for app in pairsByKeys(allApps, function(a, b)
			return string.lower(a.name) < string.lower(b.name)
		end) do
			local name = app.name
			if collision[name] or not app.show then
				goto continue
			end
			collision[name] = true
			table.insert(apps, app.name)

			local appWid = wibox.widget {
				widget = wibox.container.margin,
				right = beautiful.dpi(8),
				id = app.name,
				{
					widget = makeup.putOn(wibox.container.background, {bg = bgcolor}, {wibox = opts.menu}),
					shape = helpers.rrect(beautiful.radius or base.radius),
					id = 'bg',
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
										image = gears.surface.load_uncached_silently(app.icon, extrautils.apps.lookup_icon('application-x-executable')),
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
										text = name,
										font = beautiful.fontName .. ' Medium 12',
										widget = wibox.widget.textbox
									},
									app.description and {
										layout = wibox.container.place,
										halign = 'left',
										forced_width = beautiful.dpi(360),
										forced_height = beautiful.dpi(22),
										{
											widget = w.textbox,
											color = beautiful.fg_sec,
											text = app.description
										}
									} or nil
								}
							}
						}
					}
				}
			}

--[[
			table.insert(appWidgets, {
				widget = appWid,
				name = name
			})
]]--
			appWid.buttons = {
				awful.button({}, 1, function()
					opts.menu:off()
					app.launch()
					resetSearch()
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
		toggler = function(open)
			appList.scroll_factor = 0
			if not open then
				resetSearch()
			end
		end
	})
end

function M.create(opts)
	opts = opts or {}
	local bgcolor = opts.bg or 'bg_popup'

	local startMenu = helpers.aaWibox {
		height = beautiful.dpi(580),
		width = beautiful.dpi(460),
		bg = bgcolor,
		rrectRadius = beautiful.radius,
		ontop = true,
		visible = false
	}
	opts.menu = startMenu
	local w, width, height = M.new(opts)

	startMenu:setup(w)

	return startMenu
end

return M
