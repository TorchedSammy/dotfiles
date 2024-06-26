local colors = require 'themes.colors.syntax'
if not awesome then return colors end

local xresources = require 'beautiful.xresources'
local helpers = require 'helpers'
local dpi = xresources.apply_dpi

local theme = require 'themes.common'

-- join theme and colors
local gears = require 'gears'
theme = gears.table.join(theme, colors)

theme.fontName = 'Nimbus Sans'
theme.font = 'Nimbus Sans Regular 12'
theme.font_bold     = 'Nimbus Sans Bold 12'

theme.gradientColors = {
	'#86e0f0',
	'#9cfa74'
}
theme.accent = theme.gradientColors[1]
theme.bg_normal = theme.xbackground
theme.bg_sec = helpers.shiftColor(theme.bg_normal, 8)
theme.bg_normal_opposite = '#030303'
theme.bg_sec_opposite = '#1a1a1a'
theme.bg_tert_opposite = '#262626'
theme.bg_focus = theme.bg_normal
theme.bg_urgent = theme.bg_normal
theme.bg_minimize = theme.bg_normal

theme.fg_normal = theme.xforeground
theme.fg_sec = helpers.shiftColor(theme.xcolor12, 8)
theme.fg_normal_opposite = helpers.invertColor(theme.bg_normal_opposite)
theme.fg_sec_opposite = helpers.invertColor(theme.bg_sec_opposite)
theme.fg_tert = theme.xcolor12
theme.fg_focus = theme.fg_normal
theme.fg_urgent = theme.fg_normal
theme.fg_minimize = theme.fg_sec

theme.useless_gap   = dpi(6)
theme.border_width  = 0
theme.border_normal  = theme.fg_normal
theme.border_focus  = theme.fg_normal

theme.titlebars = true
theme.titlebar_type = 'syntax'
theme.titlebar_height = dpi(32)
theme.titlebar_bg = '#00000000'
theme.titlebar_bg_real = theme.xbackground
theme.titlebar_bg_sec = theme.xcolor8
theme.titlebar_bg_sec2 = theme.xcolor10

theme.notification_bg = theme.bg_sec
theme.notification_position = 'bottom_right'
theme.notification_icon_size = dpi(140)
theme.notification_width = dpi(480)
theme.notification_height = dpi(180)
theme.notification_border_color = theme.xforeground
theme.notification_border_width = 3
theme.notification_padding = theme.useless_gap * 2

theme.bar = 'syntax'
theme.wibar_height = dpi(32)
theme.topbar_height = dpi(46)

theme.wibar_bg = theme.bg_normal
theme.bg_systray = theme.bg_normal_opposite

local function rep(t)
	local tbl = {}
	for _ = 1, 9 do
		table.insert(tbl, t)
	end
	return tbl
end

theme.taglist_text_font = "Microns 12"
theme.taglist_number = 7
theme.taglist_text_empty    = rep ''
theme.taglist_text_occupied = rep ''
theme.taglist_text_focused  = rep ''
theme.taglist_text_urgent   = rep ''

theme.taglist_text_color_empty    = rep(theme.xcolor14)
theme.taglist_text_color_occupied  = rep(theme.fg_normal_opposite)
theme.taglist_text_color_focused  = rep(theme.xcolor6)
theme.taglist_text_color_urgent   = rep(theme.xcolor1)


theme.wallpaper = theme.config_path..'/wallpapers/SYNTAX.png'
theme.picom_conf = 'picom'

return theme

