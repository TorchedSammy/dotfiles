pcall(require, 'luarocks.loader')

local makeup = require 'ui.makeup'
makeup.setupTheme()

local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local settings = require 'conf.settings'
local widgets = require 'ui.widgets'
local wibox = require 'wibox'

local unpack = unpack or table.unpack

local function setMakeupVar(var, value)
	settings.set(var, value, false)
	local varStringied
	if type(value) == 'boolean' then
		varStringied = tostring(value)
	elseif type(value) == 'string' then
		varStringied = '\'' .. value .. '\''
	else
		error(string.format('unhandled type for makeup var %s', type(value)))
	end

	awful.spawn.easy_async(string.format([[ awesome-client "
		local settings = require 'conf.settings'
		settings.%s = %s
		require 'ui.makeup'.retheme()
	"]], var, varStringied), function() 
		makeup.retheme()
	end)
end

local pagesList = wibox.layout.fixed.vertical()
local function createPageNavigator()
	local btn = widgets.button {
		bg = beautiful.bg_normal,
		text = 'Theme',
		icon = 'palette',
		align = 'left',
		height = beautiful.dpi(40),
		size = beautiful.dpi(20),
		fontSize = beautiful.dpi(16),
		margin = beautiful.dpi(6)
	}

	return btn
end

local function titleWidget(text)
	return wibox.widget {
		widget = wibox.widget.textbox,
		font = beautiful.fontName .. ' Semibold 24',
		text = text
	}
end

local function section(title, widgets)
	return wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = beautiful.dpi(10),
		titleWidget(title),
		{
			layout = wibox.layout.fixed.vertical,
			spacing = beautiful.dpi(15),
			unpack(widgets)
		}
	}
end

local function subsection(title, widgets)
	return wibox.widget {
		layout = wibox.layout.fixed.vertical,
		spacing = beautiful.dpi(3),
		title and {
			widget = wibox.widget.textbox,
			font = beautiful.fontName .. ' Semibold 16',
			--markup = helpers.colorize_text(title or '', beautiful.fg_sec),
			text = title
		} or nil,
		{
			layout = wibox.layout.fixed.vertical,
			spacing = beautiful.dpi(7),
			unpack(widgets)
		}
	}
end

local imageFileExts = {
	'*.jpg', '*.jpeg',
	'*.png'
}

local wallpaperShow = wibox.widget {
	widget = wibox.widget.imagebox,
	clip_shape = helpers.rrect(beautiful.radius),
	image = beautiful.wallpaper
}

local function button(opts)
	return wibox.widget {
		layout = wibox.container.place,
		halign = opts.halign,
		widgets.button(opts)
	}
end

local function colorSquare(var)
	return wibox.widget {
		layout = wibox.container.place,
		halign = 'left',
		{
			widget = wibox.container.constraint,
			strategy = 'exact',
			width = beautiful.dpi(32), height = beautiful.dpi(32),
			{
				widget = makeup.putOn(wibox.container.background, {bg = var}),
			}
		}
	}
end

local function setting(opts)
	local setter
	if not opts.type then
		error 'settings type is required'
	end

	if opts.type == 'switch' then
		setter = widgets.switch {
			handler = opts.handler,
			bg = 'accent',
			on = opts.default
		}
	else
		error(string.format('invalid setting type %s', opts.type))
	end

	return wibox.widget {
		layout = wibox.layout.align.horizontal,
		expand = 'none',
		{
			layout = wibox.layout.fixed.vertical,
			{
				widget = wibox.widget.textbox,
				text = opts.name
			},
			{
				widget = wibox.widget.textbox,
				markup = helpers.colorize_text(opts.description or '', beautiful.fg_sec),
			},
		},
		nil,
		{
			layout = wibox.container.margin,
			right = beautiful.dpi(20),
			{
				layout = wibox.container.place,
				halign = 'right',
				setter
			}
		}
	}
end

local colorSquares = {}
for _, var in ipairs {'xcolor1', 'xcolor2', 'xcolor3', 'xcolor4', 'xcolor5', 'xcolor6'} do
	local square = colorSquare(var)
	square.buttons = {
		awful.button({}, 1, function()
			setMakeupVar('accent', var)
		end)
	}

	table.insert(colorSquares, square)
end

local themePage = wibox.widget {
	layout = wibox.layout.fixed.vertical,
	spacing = beautiful.dpi(7),
	section('Wallpaper', {
		subsection(nil, {
			{
				widget = wibox.container.constraint,
				height = beautiful.dpi(270),
				wallpaperShow,
			},
			button {
				halign = 'left',
				bg = beautiful.bg_sec,
				text = 'Choose Wallpaper',
				icon = 'wallpaper',
				height = beautiful.dpi(32),
				size = beautiful.dpi(24),
				onClick = function()
					awful.spawn.with_line_callback(string.format('zenity --file-selection --file-filter="Images | %s")', table.concat(imageFileExts, ' ')), {
						stdout = function(out)
							if out:match '^/' then
								wallpaperShow.image = out
								settings.set('wallpaper', out, false)

								awful.spawn.easy_async(string.format([[ awesome-client "
									local settings = require 'conf.settings'
									settings.wallpaper = '%s'
									require 'ui.makeup'.retheme()
								"]], out), function() 
									makeup.retheme()
								end)
							end
						end
					})
				end
			}
		})
	}),
	section('Colors', {
		subsection('Accent', {
			{
				layout = wibox.layout.fixed.horizontal,
				spacing = beautiful.dpi(7),
				unpack(colorSquares)
			}
		}),
		setting {
			name = 'Dynamic Colors',
			description = 'Themes the environment based on the wallpaper.',
			type = 'switch',
			default = settings.dynamicTheme,
			handler = function(on)
				settings.set('dynamicTheme', on, false)

				awful.spawn.easy_async(string.format([[ awesome-client "
					local settings = require 'conf.settings'
					settings.dynamicTheme = %s
					require 'ui.makeup'.retheme()
				"]], tostring(on)), function() 
					makeup.retheme()
				end)
			end
		}
	})
}

pagesList:add(createPageNavigator())

local ratio = wibox.layout.ratio.horizontal()
local app = wibox.widget {
	layout = ratio,
	spacing = beautiful.dpi(25),
	spacing_widget = {
		widget = wibox.container.constraint,
		width = beautiful.dpi(2),
		{
			widget = wibox.widget.separator,
			color = beautiful.separator,
			thickness = beautiful.dpi(3),
		}
	},
	pagesList,
	themePage
}
ratio:adjust_ratio(1, 0, 0.2, 0.8)

local box = wibox {
	width = 683,
	height = 384,
	bg = beautiful.bg_normal,
	widget = {
		widget = wibox.container.margin,
		margins = beautiful.dpi(10),
		app
	},
	visible = true,
	decorated = true,
	title = 'Settings',
	resizable = true
}

awesome.connect_signal('makeup::put_on', function(oldTheme)
	helpers.transitionColor {
		old = oldTheme.bg_normal,
		new = beautiful.bg_normal,
		transformer = function(c) box.bg = c end,
		duration = 5,
	}
end)

box:connect_signal('property::visible', function()
	require 'awexygen'.app.request_exit()
end)
