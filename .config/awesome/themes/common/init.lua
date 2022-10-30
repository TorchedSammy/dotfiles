local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local config_path = gfs.get_configuration_dir()
local helpers = require("helpers")

function layoutimg(name)
	return config_path..'/images/layouts/'..name
end
local theme = {}

theme.gfs = gfs
theme.dpi = dpi
theme.config_path = config_path
theme.themes_path = themes_path
theme.master_width_factor = 0.6

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

theme.font          = "SF Pro Text Regular 10"

theme.bg_normal     = theme.xbackground
theme.bg_focus      = theme.bg_normal
theme.bg_urgent     = theme.bg_normal
theme.bg_minimize   = theme.bg_normal

theme.fg_normal     = theme.xforeground
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.useless_gap   = dpi(10)
theme.border_width  = dpi(0)
theme.border_normal = theme.bg_normal
theme.border_focus  = theme.bg_normal
theme.border_marked = theme.xcolor0

theme.titlebars = true
theme.titlebar_type = 'default'
theme.titlebar_height = dpi(30)
theme.titlebar_bg = theme.xcolor0
-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

theme.tasklist_plain_task_name = true 
theme.taglist_number = 8

-- Generate taglist squares:
local taglist_square_size = dpi(4)
theme.taglist_squares_sel = theme_assets.taglist_squares_sel(
    taglist_square_size, theme.fg_normal
)
theme.taglist_squares_unsel = theme_assets.taglist_squares_unsel(
    taglist_square_size, theme.fg_normal
)

-- Variables set for theming notifications:
-- notification_font
theme.notification_bg = theme.xcolor0
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]
theme.notification_font = "SF Pro Text Regular 10"
theme.notification_shape = helpers.rrect(dpi(8))
theme.notification_margin = dpi(10)
theme.notification_padding = dpi(10)
theme.notification_spacing = dpi(10)
theme.notification_border_width = dpi(0)
theme.notification_icon_size = dpi(80)
theme.notification_position = 'top_right'

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themes_path.."default/submenu.png"
--theme.menu_submenu_icon = gears.color.recolor_image(color.submenu, color.fg)
theme.menu_font     = theme.font
theme.menu_bg_normal     = theme.bg
theme.menu_bg_focus     = theme.bg_sec
theme.menu_fg_normal    = theme.fg
theme.menu_fg_focus     = theme.fg
theme.menu_height    = dpi(25)
theme.menu_width     = dpi(100)

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"
theme.hotkeys_modifiers_fg = "#5c6370"
theme.lock_screen_bg = theme.xbackground.."BF"
theme.lock_screen_fg = theme.xforeground
theme.exit_screen_bg = theme.lock_screen_bg
theme.exit_screen_fg = theme.lock_screen_fg
--theme.bar = 'bar here'
theme.wibar_height = dpi(26)
theme.wibar_spacing = dpi(10)
theme.systray_icon_size = dpi(18)
theme.systray_icon_spacing = theme.wibar_spacing / 2

theme.corner_radius = dpi(6)
theme.wibar_bg = theme.bg_normal
theme.bg_systray = theme.wibar_bg

-- Wibar
theme.volume_bar_color = theme.xcolor2
theme.ram_bar_color = theme.xcolor4
theme.battery_bar_color = theme.xcolor1
-- Noodle Text Taglist
theme.taglist_text_font = "Font Awesome 11"
theme.taglist_text_empty    = {"","","","","","","","",""}
theme.taglist_text_occupied = {"","","","","","","","",""}
theme.taglist_text_focused  = {"","","","","","","","",""}
theme.taglist_text_urgent   = {"⚡","⚡","⚡","⚡","⚡","⚡","⚡","⚡","⚡"}

theme.taglist_text_color_empty    = { theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7, theme.xcolor7 }
theme.taglist_text_color_occupied  = { theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4, theme.xcolor5, theme.xcolor6, theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4 }
theme.taglist_text_color_focused  = { theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4, theme.xcolor5, theme.xcolor6, theme.xcolor1, theme.xcolor2, theme.xcolor3, theme.xcolor4 }
theme.taglist_text_color_urgent   = { theme.xcolor9, theme.xcolor10, theme.xcolor11, theme.xcolor12, theme.xcolor13, theme.xcolor14, theme.xcolor9, theme.xcolor10, theme.xcolor11, theme.xcolor12 }

-- Define the image to load
theme.titlebar_close_button_normal = themes_path.."default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = themes_path.."default/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = themes_path.."default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path.."default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path.."default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = themes_path.."default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path.."default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = themes_path.."default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path.."default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = themes_path.."default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path.."default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path.."default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path.."default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = themes_path.."default/titlebar/maximized_focus_active.png"

theme.layout_fairh = layoutimg("fairhw.png")
theme.layout_fairv = layoutimg("fairvw.png")
theme.layout_floating  = layoutimg("floatingw.png")
theme.layout_magnifier = layoutimg("magnifierw.png")
theme.layout_max = layoutimg("maxw.png")
theme.layout_fullscreen = layoutimg("fullscreenw.png")
theme.layout_tilebottom = layoutimg("tilebottomw.png")
theme.layout_tileleft   = layoutimg("tileleftw.png")
theme.layout_tile = layoutimg("tilew.png")
theme.layout_tiletop = layoutimg("tiletopw.png")
theme.layout_spiral  = layoutimg("spiralw.png")
theme.layout_dwindle = layoutimg("dwindlew.png")
theme.layout_cornernw = layoutimg("cornernww.png")
theme.layout_cornerne = layoutimg("cornernew.png")
theme.layout_cornersw = layoutimg("cornersww.png")
theme.layout_cornerse = layoutimg("cornersew.png")

theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)
theme_assets.recolor_layout(theme, theme.xforeground)
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
