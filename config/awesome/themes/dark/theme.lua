-- Dark - A theme for those hiding in darkness.
-- DEPRECATED: WILL NOT BE SUPPORTED OR UPDATED
-- I don't like using this theme anymore, but someone else might try
-- it and like it.

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
theme.xcolor15    ="#ebe1e7"

theme.useless_gap   = dpi(6)
theme.border_width  = dpi(1)

theme.titlebars = false

theme.bar = 'dark'
theme.wibar_height = dpi(30)

theme.wallpaper = theme.config_path.."/wallpapers/dark.png"

return theme

