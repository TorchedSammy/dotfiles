local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = require('themes.common')

theme.xbackground = "#1C1E26"
theme.xforeground = "#DCDFE4"
theme.xcolor0     = "#1C1E26"
theme.xcolor1     = "#E95678"
theme.xcolor2     = "#FAB795"
theme.xcolor3     = '#29D398'
theme.xcolor4     = "#59E1E3"
theme.xcolor5     = "#26BBD9"
theme.xcolor6     = "#EE64AC"
theme.xcolor7     = "#F09383"
theme.xcolor8     = "#a49da1"
theme.xcolor9     = "#72BCE0"
theme.xcolor10    = "#AB93A0"
theme.xcolor11    = "#D2A1B0"
theme.xcolor12    = "#E4B5CC"
theme.xcolor13    = "#A4C8DE"
theme.xcolor14    = "#EDCCD6"
theme.xcolor15    = "#ebe1e7"

theme.bg_normal     = theme.xbackground
theme.bg_sec        = '#6F6F70'
theme.bg_focus      = theme.bg_normal
theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = theme.bg_normal

theme.fg_normal     = theme.xforeground

theme.useless_gap   = dpi(10)
theme.border_width  = dpi(6)
theme.border_normal  = theme.bg_normal -- Outer Border
theme.border_focus  = theme.bg_normal -- Outer Border
theme.titlebar_bg  = theme.xcolor6 -- Inner Border

theme.titlebars = true
theme.titlebar_type = 'default'

theme.bar = 'clouds'
theme.wibar_bg = theme.bg_normal
theme.wibar_spacing = dpi(14)

theme.notification_border_color = theme.titlebar_bg
theme.notification_border_width = theme.border_width
theme.notification_position = 'bottom_right'
theme.notification_padding = dpi(45)
theme.notification_spacing = dpi(8)
theme.notification_shape = nil

theme.taglist_text_font = 'Typicons 14'
theme.taglist_text_color_empty    = { theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7 }
theme.taglist_text_color_occupied  = { theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4, theme.xcolor5, theme.xcolor6, theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4 }
theme.taglist_text_color_focused  = { theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4, theme.xcolor5, theme.xcolor6, theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4 }
theme.taglist_text_color_urgent   = { theme.xcolor9, theme.xcolor10, theme.xcolor11, theme.xcolor12, theme.xcolor13, theme.xcolor14, theme.xcolor9, theme.xcolor10, theme.xcolor11, theme.xcolor12 }

theme.bg_systray = theme.wibar_bg

theme.wallpaper = theme.config_path.."/wallpapers/clouds1.jpg"

theme.picom_conf = "rounded"

return theme

