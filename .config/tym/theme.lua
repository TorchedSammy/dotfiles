local oldPackagePath = package.path
package.path = package.path .. ';' .. os.getenv 'HOME' .. '/.config/awesome/?.lua'

local awesomeDir = '~/.config/awesome'
local awmThemename = dofile((awesomeDir .. '/conf/settings.lua'):gsub('~', os.getenv 'HOME')).theme
local themePath = awesomeDir .. '/themes/colors/' .. awmThemename .. '.lua'
local thm = dofile(themePath:gsub('~', os.getenv('HOME')))
local bg = thm.xbackground
local fg = thm.xforeground

package.path = oldPackagePath

local theme = {
	color_background = bg,
	color_foreground = fg,
	color_bold = fg,
	color_cursor = fg,
	color_cursor_foreground = bg,
	color_highlight = fg,
	color_highlight_foreground = bg,
}

for i = 0, 15 do
	theme['color_' .. i] = thm['xcolor' .. i]
end

return theme
