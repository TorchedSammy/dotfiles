local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = require('themes.common')
local colors = require 'themes.colors.blossom'

-- join theme and colors
local gears = require 'gears'
theme = gears.table.join(theme, colors)

theme.bg_normal     = theme.xbackground
theme.bg_sec        = '#6F6F70'
theme.bg_focus      = theme.bg_normal
theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = theme.bg_normal

theme.fg_normal     = theme.xforeground

theme.titlebars = true
theme.titlebar_type = 'default'
theme.titlebar_bg = "#332b3d" .. "e6"

--theme.bar = 'bar here'
theme.wibar_height = dpi(28)
theme.wibar_bg = theme.bg_normal .. "d6"

theme.wallpaper = theme.config_path.."/wallpapers/blossoms2.jpg"

theme.picom_conf = "blur-shadow"
theme.exp_picom_bknd = true

return theme

