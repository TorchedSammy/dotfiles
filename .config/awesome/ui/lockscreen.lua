local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local pam = require 'liblua_pam'
local rubato = require 'libs.rubato'
local settings = require 'conf.settings'
local wibox = require 'wibox'
local w = require 'ui.widgets'
local inputbox = require 'ui.widgets.inputbox'

local locked = false
local M = {}

local scr = awful.screen.focused()
local lockscreenEntry = wibox {
	width = scr.geometry.width,
	height = scr.geometry.height,
	ontop = true,
	visible = false
}

local lockscreen = wibox {
	width = scr.geometry.width,
	height = scr.geometry.height,
	ontop = true,
	visible = true
}

local passwordInput = inputbox {
	password_mode = true,
	mouse_focus = true,
	fg = beautiful.fg_normal,
	font = beautiful.fontName .. ' Medium 14',
	text_hint = 'Password'
}

local kg = awful.keygrabber {
	keypressed_callback = function(_, mod, key)
		if key ~= ' ' then return end

		lockscreen:off()
	end
}

local oldPwKeygrabber = passwordInput.start_keygrabber
function passwordInput:start_keygrabber()
	kg:stop()
	oldPwKeygrabber(self)
end

local oldPwUnfocus = passwordInput.unfocus
function passwordInput:unfocus()
	kg:start()
	oldPwUnfocus(self)
end

local function decToHex(dec)
	return string.format('%0x', math.floor(dec * 255))
end

local function makeGradient(geo, solid, transparent)
    return {
        type  = 'linear' ,
        from  = {
            0,
            geo.height
        },
        to = {
            geo.width,
            geo.height
        },
        stops = {
            {
                0,
                solid .. decToHex(0.9)
            },
            {
                0.4,
                solid .. decToHex(0.6)
            },
            {
                0.6,
                solid .. decToHex(0.6)
            },
            {
                0.9,
                solid .. decToHex(0.7)
            },
            {
                1,
                solid .. decToHex(0.9)
            }
        }
    }
end

local bottomInfo = wibox.widget {
	layout = wibox.layout.align.horizontal,
	expand = 'none',
	{
		layout = wibox.layout.fixed.horizontal,
		w.button {
			icon = 'power2',
			onClick = function() end,
			size = beautiful.dpi(36)
		}
	},
	nil,
	{
		layout = wibox.layout.fixed.horizontal,
		spacing = beautiful.dpi(8),
		{
			layout = wibox.layout.fixed.horizontal,
			w.wifi { size = beautiful.dpi(36) }
		},
		{
			layout = wibox.layout.fixed.horizontal,
			w.battery { size = beautiful.dpi(36) }
		},
		w.icon {name = 'notification', size = beautiful.dpi(36)}
	}
}

local incorrectPass = wibox.widget {
	widget = wibox.widget.textbox,
	font = beautiful.fontName .. ' Medium Italic 12',
	markup = 'Incorrect Password',
	visible = false
}

local entryContentsLayout = wibox.layout.align.vertical()
entryContentsLayout.visible = false

local function unlock()
	locked = false

	lockscreenEntry.visible = false
	entryContentsLayout.visible = false
	incorrectPass.visible = false
	passwordInput:unfocus()
	passwordInput:set_text('')

	lockscreen:off()
	root.keys(globalkeys)
end

lockscreenEntry:setup {
	layout = wibox.layout.stack,
	{
		widget = wibox.widget.imagebox,
		horizontal_fit_policy = 'cover',
		vertical_fit_policy = 'cover',
		valign = 'center',
		halign = 'center',
		image = settings.lockWallpaper,
	},
	{
		widget = wibox.container.background,
		bg = makeGradient(scr.geometry, '#000000'),
		{
			widget = wibox.container.margin,
			margins = beautiful.dpi(100),
			{
				layout = entryContentsLayout,
				expand = 'none',
				nil,
				{
					layout = wibox.layout.fixed.vertical,
					spacing = beautiful.dpi(16),
					{
						layout = wibox.container.place,
						{
							w.imgwidget('avatar.jpg', {
								clip_shape = gears.shape.circle
							}),
							widget = wibox.container.constraint,
							strategy = 'exact',
							width = beautiful.dpi(120),
							height = beautiful.dpi(120)
						},
					},
					{
						layout = wibox.container.place,
						{
							layout = wibox.layout.fixed.vertical,
							{
								layout = wibox.layout.fixed.horizontal,
								{	
									widget = wibox.container.constraint,
									strategy = 'exact',
									width = beautiful.dpi(250),
									{
										widget = wibox.container.background,
										bg = beautiful.bg_sec,
										shape = helpers.rrect(beautiful.radius / 2),
										{
											widget = wibox.container.margin,
											margins = beautiful.dpi(8),
											passwordInput.widget
										}
									}
								},
								{
									widget = wibox.container.rotate,
									direction = 'east',
									w.button('expand-more', {
										bg = '#00000000',
										onClick = function()
											local authenticated = pam.auth_current_user(passwordInput:get_text())
											if authenticated then
												unlock()
											else
												incorrectPass.visible = true
											end
										end,
										size = beautiful.dpi(32)
									})
								}
							},
							{
								widget = wibox.container.margin,
								left = beautiful.dpi(8),
								incorrectPass
							}
						}
					}
				},
				bottomInfo
			}
		}
	}
}

lockscreen:setup {
	layout = wibox.layout.stack,
	{
		widget = wibox.widget.imagebox,
		horizontal_fit_policy = 'cover',
		vertical_fit_policy = 'cover',
		valign = 'center',
		halign = 'center',
		image = settings.lockWallpaper,
	},
	{
		widget = wibox.container.background,
		bg = makeGradient(scr.geometry, '#000000'),
		{
			widget = wibox.container.margin,
			margins = beautiful.dpi(100),
			{
				layout = wibox.layout.align.vertical,
				expand = 'none',
				{
					layout = wibox.layout.fixed.horizontal,
					spacing = beautiful.dpi(8),
					{
						w.imgwidget('avatar.jpg', {
							clip_shape = gears.shape.circle
						}),
						widget = wibox.container.constraint,
						strategy = 'exact',
						width = beautiful.dpi(48),
						height = beautiful.dpi(48)
					},
					{
						widget = wibox.widget.textbox,
						markup = helpers.colorize_text(('roseberry'):gsub('(%a)([%w_\']*)', function(a, b) return a:upper() .. b:lower() end), beautiful.fg_normal),
						font = beautiful.fontName .. ' Semibold 16'
					}
				},
				{
					layout = wibox.layout.fixed.vertical,
					{
						widget = wibox.widget.textclock,
						format = '%-I:%M %p',
						font = beautiful.fontName .. ' Bold 52',
					},
					{
						widget = wibox.widget.textclock,
						format = '%B %e',
						font = beautiful.fontName .. ' Bold 52',
					},
					{
						widget = wibox.widget.textclock,
						format = helpers.colorize_text('%A', beautiful.fg_tert),
						font = beautiful.fontName .. ' Bold 36',
					}
				},
				bottomInfo
			}
		}
	}
}

helpers.slidePlacement(lockscreen, {
	placement = function() end,
	heights = {
		hide = scr.geometry.height,
		reveal = 0
	},
	invert = true,
	open = false
})

function M.locked()
	return locked
end

function M.lock()
	root.keys = {}
	locked = true
	lockscreenEntry.visible = true
	entryContentsLayout.visible = true
	lockscreen:on()
	kg:start()
end

return M
