local awesomeDir = '~/.config/awesome'
local themename = dofile((awesomeDir .. '/conf/settings.lua'):gsub('~', os.getenv 'HOME')).theme
local themePath = awesomeDir .. '/themes/colors/' .. themename .. '.lua'
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

for i = 0, 15 do
	theme['color_' .. i] = thm['xcolor' .. i]
end

return theme
