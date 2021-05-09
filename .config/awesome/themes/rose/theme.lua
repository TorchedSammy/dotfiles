local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = require('themes.common')

theme.xbackground = "#0D100D"
theme.xforeground = "#d896a0"
theme.xcolor0     = "#0D100D"
theme.xcolor1     = "#395345"
theme.xcolor2     = "#2D5A53"
theme.xcolor3     = "#8F1616"
theme.xcolor4     = "#AF1818"
theme.xcolor5     = "#A62227"
theme.xcolor6     = "#CC1D1F"
theme.xcolor7     = "#d896a0"
theme.xcolor8     = "#976970"
theme.xcolor9     = "#395345"
theme.xcolor10    = "#2D5A53"
theme.xcolor11    = "#8F1616"
theme.xcolor12    = "#AF1818"
theme.xcolor13    = "#A62227"
theme.xcolor14    = "#CC1D1F"
theme.xcolor15    = "#d896a0"

theme.bar = 'landscape'
theme.wibar_height = dpi(30)

theme.taglist_text_occupied  = {"","","","","","","","",""}
theme.taglist_text_focused = {"","","","","","","","",""}

heme.wallpaper = gfs.get_configuration_dir().."/wallpapers/roses.jpg"

return theme

