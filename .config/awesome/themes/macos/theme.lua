local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = require('themes.common')

theme.xbackground = "#1d1f21"
theme.xforeground = "#e0e0e0"
theme.xcolor0     = "#1d1f21"
theme.xcolor1     = "#d04645"
theme.xcolor2     = "#77b755"
theme.xcolor3     = "#f4c94d"
theme.xcolor4     = "#3E89E7"
theme.xcolor5     = "#e25e9c"
theme.xcolor6     = "#5EDFE2"
theme.xcolor7     = "#f0f0f0"
theme.xcolor8     = "#999999"
theme.xcolor9     = "#DF5554"
theme.xcolor10    = "#8ACC68"
theme.xcolor11    = "#FDD565"
theme.xcolor12    = "#4993F0"
theme.xcolor13    = "#EB6AA6"
theme.xcolor14    = "#6FEBEE"
theme.xcolor15    = "#ffffff"

theme.bg_normal     = theme.xbackground
theme.bg_sec        = '#6F6F70'
theme.bg_focus      = theme.bg_normal
theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = theme.bg_normal

theme.fg_normal     = theme.xforeground
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.useless_gap   = dpi(6)

theme.titlebars = true
theme.titlebar_type = 'macos'
theme.titlebar_bg = theme.xcolor0

theme.notification_bg = theme.xcolor0
theme.notification_border_color = theme.xcolor7
theme.notification_border_width = dpi(1)

theme.bar = 'macos'
theme.wibar_height = dpi(27)

theme.wibar_bg = theme.bg_normal
theme.bg_systray = theme.wibar_bg

theme.wallpaper = theme.config_path.."/wallpapers/bigsur.jpg"
theme.picom_conf = 'picom-macos'

return theme

