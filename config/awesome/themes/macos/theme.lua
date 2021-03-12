local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = {}

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

theme.useless_gap   = dpi(6)

theme.titlebar_type = 'macos'

theme.bar = 'macos'
theme.wibar_height = dpi(27)

theme.wallpaper = gfs.get_configuration_dir().."/wallpapers/bigsur.jpg"

return theme

