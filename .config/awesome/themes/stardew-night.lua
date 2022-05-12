local colors = require 'themes.colors.stardew-night'
if not awesome then return colors end

local gears = require 'gears'
local theme = require 'themes.stardew'
theme = gears.table.join(theme, colors)

theme.bg_normal     = theme.xbackground
theme.bg_sec        = theme.xcolor8
theme.bg_focus      = theme.bg_normal
theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = theme.bg_normal

theme.fg_normal     = theme.xforeground

theme.fg_focus      = '#ffffff'
theme.fg_urgent     = '#ffffff'
theme.fg_minimize   = '#ffffff'

theme.border_normal  = theme.xcolor9
theme.border_focus  = theme.xcolor11

theme.titlebar_bg = theme.bg_normal

theme.notification_bg = theme.bg_normal
theme.notification_border_color = theme.bg_sec

theme.wibar_bg = theme.bg_normal
theme.bg_systray = theme.wibar_bg

theme.taglist_text_color = theme.fg_normal

theme.wallpaper = theme.config_path..'/wallpapers/stardew3.png'

return theme

