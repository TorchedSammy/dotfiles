-- Landscape - A dark, city theme.
-- DEPRECATED: WILL NOT BE SUPPORTED OR UPDATED
-- I don't like the colors of this theme and also don't like using
-- this anymore, though others might.

local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local xrdb = xresources.get_current_theme()

local theme = require('themes.common')

theme.xbackground = "#161313"
theme.xforeground = "#e9c6cb"
theme.xcolor0     = "#161313"
theme.xcolor1     = "#3E5D83"
theme.xcolor2     = "#5E6D93"
theme.xcolor3     = "#9D7092"
theme.xcolor4     = "#D1768A"
theme.xcolor5     = "#748BAD"
theme.xcolor6     = "#9B97B4"
theme.xcolor7     = "#e9c6cb"
theme.xcolor8     = "#a38a8e"
theme.xcolor9     = "#3E5D83"
theme.xcolor10    = "#5E6D93"
theme.xcolor11    = "#9D7092"
theme.xcolor12    = "#D1768A"
theme.xcolor13    = "#748BAD"
theme.xcolor14    = "#9B97B4"
theme.xcolor15    = "#e9c6cb"

theme.bar = 'landscape'
theme.wibar_height = dpi(30)

theme.taglist_text_occupied  = {"","","","","","","","",""}
theme.taglist_text_focused = {"","","","","","","","",""}

theme.wallpaper = theme.config_path.."/wallpapers/landscape.jpg"

return theme

