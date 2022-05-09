local xresources = require 'beautiful.xresources'
local helpers = require 'helpers'
local dpi = xresources.apply_dpi

local theme = require 'themes.common'
local colors = require 'themes.colors.stardew'

-- join theme and colors
local gears = require 'gears'
theme = gears.table.join(theme, colors)

theme.font          = 'SF Pro Text Medium 12'

theme.bg_normal     = theme.xbackground
theme.bg_sec        = '#fffaf5'
theme.bg_focus      = theme.bg_normal
theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = theme.bg_normal

theme.fg_normal     = theme.xforeground
theme.fg_focus      = '#ffffff'
theme.fg_urgent     = '#ffffff'
theme.fg_minimize   = '#ffffff'

theme.useless_gap   = dpi(6)
theme.border_width  = 3
theme.border_normal  = theme.fg_normal
theme.border_focus  = theme.fg_normal
theme.client_shape = helpers.rrect(2)

theme.titlebars = true
theme.titlebar_type = 'simple'
theme.titlebar_height = dpi(32)
theme.titlebar_bg = theme.bg_normal

theme.notification_bg = theme.xbackground
theme.notification_position = 'bottom_right'
theme.notification_width = dpi(340)
theme.notification_height = dpi(100)
theme.notification_border_color = theme.xforeground
theme.notification_border_width = 3
theme.notification_padding = theme.useless_gap * 2
theme.notification_shape = helpers.rrect(2)

theme.bar = 'stardew'
theme.wibar_height = dpi(36)

theme.wibar_bg = theme.bg_normal
theme.bg_systray = theme.wibar_bg

theme.taglist_text_font = 'SF Pro Text Medium 12'
theme.taglist_text_focused = nil
theme.taglist_text_color = theme.xforeground
theme.taglist_text_color_focused = '#806e6a'

theme.wallpaper = theme.config_path..'/wallpapers/stardew2.jpg'
theme.picom_conf = 'picom-macos'

return theme

