local colors = require 'themes.colors.stardew-night'
if not awesome then return colors end

local settings = require 'conf.settings'
local xresources = require 'beautiful.xresources'
local helpers = require 'helpers'
local dpi = xresources.apply_dpi

local theme = require 'themes.common'
theme.wallpaper = settings.wallpaper or theme.config_path..'/wallpapers/mine.png'

local gears = require 'gears'
theme = gears.table.join(theme, colors)

if settings.dynamicTheme then
	local surfaces = require 'themes.colors.material-you'(theme.wallpaper)
	theme = gears.table.join(theme, surfaces)
end

theme.fontName = 'IBM Plex Sans'
theme.font          = theme.fontName .. ' Regular 12'

theme.dark = true
theme.accent = settings.dynamicTheme and theme.accent or theme[settings.accent or 'accent'] --'#8062ff'

theme.bg_normal = theme.background
theme.bg_sec = theme.backgroundSecondary
theme.bg_tert = theme.backgroundTertiary
theme.bg_quad = theme.backgroundQuad

theme.bg_popup = theme.bg_normal--helpers.shiftColor(theme.bg_normal, 2)
theme.bg_focus = theme.bg_normal
theme.bg_urgent = theme.bg_normal
theme.bg_minimize = theme.bg_normal

theme.fg_normal = theme.xforeground
theme.fg_sec = theme.xcolor12
theme.fg_tert = theme.xcolor11
theme.fg_focus = theme.fg_normal
theme.fg_urgent = theme.fg_normal
theme.fg_minimize = theme.fg_sec

theme.radius = 12
theme.useless_gap   = dpi(6)
theme.border_width  = dpi(1)
theme.border_normal  = theme.bg_sec
theme.border_focus  = theme.accent
theme.client_shape = helpers.rrect(theme.radius)

theme.titlebars = true
theme.titlebar_type = 'harmony'
theme.titlebar_height = dpi(48)
theme.titlebar_bg = theme.bg_sec

theme.notification_bg = theme.xbackground
theme.notification_position = 'bottom_right'
theme.notification_width = dpi(340)
theme.notification_height = dpi(120)
theme.notification_border_color = theme.xforeground
theme.notification_border_width = dpi(0)
theme.notification_padding = theme.useless_gap * dpi(2)
--theme.notification_shape = helpers.rrect(theme.radius)

theme.bar = 'harmony'
theme.wibar_height = dpi(45)

theme.wibar_bg = theme.bg_normal
theme.bg_systray = theme.wibar_bg

local function rep(t)
	local tbl = {}
	for _ = 1, 9 do
		table.insert(tbl, t)
	end
	return tbl
end

theme.taglist_size = dpi(12)
theme.taglist_expanded_size = dpi(24)
theme.taglist_active_gradient = false
theme.taglist_text_color_empty    = rep(theme.xcolor14)
theme.taglist_text_color_occupied  = rep(theme.xcolor7)
theme.taglist_text_color_focused  = rep(theme.accent)
theme.taglist_text_color_urgent   = rep(theme.xcolor1)

theme.task_preview_widget_bg = theme.bg_popup

--theme.wallpaper = theme.config_path..'/wallpapers/lvl374_free_v2_desktop.png'
theme.picom_conf = 'picom-harmony'

return theme

