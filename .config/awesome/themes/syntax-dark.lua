local colors = require 'themes.colors.stardew-night'
if not awesome then return colors end

local xresources = require 'beautiful.xresources'
local helpers = require 'helpers'
local dpi = xresources.apply_dpi

local theme = require 'themes.syntax'

-- join theme and colors
local gears = require 'gears'
theme = gears.table.join(theme, colors)

theme.font          = 'Nimbus Sans Regular 12'

--theme.gradientColors = {'#491979', '#0e5a75'}
theme.gradientColors = {'#ff006a', '#5900ff'}
theme.accent = theme.gradientColors[1]
theme.bg_normal = theme.xbackground
theme.bg_sec = helpers.shiftColor(theme.bg_normal, 12)
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
theme.titlebar_bg = theme.xbackground
theme.titlebar_bg_sec = theme.xcolor8
theme.titlebar_bg_sec2 = theme.xcolor10

theme.notification_bg = theme.bg_sec

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
theme.taglist_text_color_focused  = rep(theme.accent)
theme.taglist_text_color_urgent   = rep(theme.xcolor1)


theme.wallpaper = theme.config_path..'/wallpapers/SYNTAX-dark.png'
--theme.wallpaper = theme.config_path .. '/wallpapers/DodecaPink.jpg'
theme.picom_conf = 'picom'

return theme

