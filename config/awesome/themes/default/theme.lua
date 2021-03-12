local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = require('themes.common')

theme.xbackground = "#110f1c"
theme.xforeground = "#ebe1e7"
theme.xcolor0     = "#110f1c"
theme.xcolor1     = "#72BCE0"
theme.xcolor2     = "#AB93A0"
theme.xcolor3     = "#D2A1B0"
theme.xcolor4     = "#E4B5CC"
theme.xcolor5     = "#A4C8DE"
theme.xcolor6     = "#EDCCD6"
theme.xcolor7     = "#ebe1e7"
theme.xcolor8     = "#a49da1"
theme.xcolor9     = "#72BCE0"
theme.xcolor10    = "#AB93A0"
theme.xcolor11    = "#D2A1B0"
theme.xcolor12    = "#E4B5CC"
theme.xcolor13    = "#A4C8DE"
theme.xcolor14    = "#EDCCD6"
theme.xcolor15    = "#ebe1e7"

theme.titlebars = true
theme.titlebar_type = 'default'
theme.titlebar_bg = "#332b3d" .. "e6"

--theme.bar = 'bar here'
theme.wibar_bg = theme.bg_normal .. "99"

theme.wallpaper = theme.config_path.."/wallpapers/blossoms.jpg"

theme.picom_conf = "blur-shadow"

return theme

