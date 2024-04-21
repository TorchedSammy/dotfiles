local oldPackagePath = package.path
package.path = package.path .. ';' .. os.getenv 'HOME' .. '/.config/awesome/?.lua'

local color = require 'modules.color'

local f = io.open(os.getenv 'HOME' .. '/.local/share/awesome/config.json')
local obj = load('return ' .. f:read '*a':gsub('("[^"]-"):', '[%1]='))()
local awesomeDir = '~/.config/awesome'
local awmThemename = obj.theme

local themePath = awesomeDir .. '/themes/' .. awmThemename .. '.lua'
local thm = dofile(themePath:gsub('~', os.getenv('HOME')))
local bg = thm.xbackground
local fg = thm.xforeground

local theme = {
	color_background = bg,
	color_foreground = fg,
	color_bold = fg,
	color_cursor = fg,
	color_cursor_foreground = bg,
	color_highlight = fg,
	color_highlight_foreground = bg,
}

for i = 0, 7 do
	theme['color_' .. i] = thm['xcolor' .. i]
	theme['color_' .. i + 8] = color.shift(thm['xcolor' .. i], 25)
end

return theme
