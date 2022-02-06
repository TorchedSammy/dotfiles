local xresources = require('beautiful.xresources')
local dpi = xresources.apply_dpi

local theme = require('themes.common')
local colors = require 'themes.colors.macos'

-- join theme and colors
local gears = require 'gears'
theme = gears.table.join(theme, colors)

theme.font          = 'SF Pro Text Medium 10'

theme.bg_normal     = theme.xbackground
theme.bg_sec        = '#6F6F70'
theme.bg_focus      = theme.bg_normal
theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = theme.bg_normal

theme.fg_normal     = theme.xforeground
theme.fg_focus      = '#ffffff'
theme.fg_urgent     = '#ffffff'
theme.fg_minimize   = '#ffffff'

theme.useless_gap   = dpi(6)
theme.border_width  = dpi(1)
theme.border_normal  = theme.bg_sec
theme.border_focus  = theme.bg_sec

theme.titlebars = true
theme.titlebar_type = 'macos'
theme.titlebar_height = dpi(32)
theme.titlebar_bg = theme.bg_normal

theme.notification_bg = theme.xcolor0
theme.notification_width = dpi(340)
theme.notification_height = dpi(100)
theme.notification_border_color = theme.xcolor0
theme.notification_border_width = dpi(0)

theme.bar = 'macos'
theme.wibar_height = dpi(30)

theme.wibar_bg = theme.bg_normal
theme.bg_systray = theme.wibar_bg

theme.wallpaper = theme.config_path..'/wallpapers/blossoms.jpg'
theme.picom_conf = 'picom-macos'

return theme

