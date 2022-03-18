local style = require "core.style"
local common = require "core.common"

local awesomeDir = '~/.config/awesome'
local themename = dofile((awesomeDir .. '/conf/settings.lua'):gsub('~', os.getenv 'HOME')).theme
local themePath = awesomeDir .. '/themes/colors/' .. themename .. '.lua'
local thm = dofile(themePath:gsub('~', os.getenv('HOME')))
local bg = thm.xbackground
local fg = thm.xforeground

if themename == 'clouds' then
	local green = thm.xcolor2
	local yellow = thm.xcolor3
	thm.xcolor2 = yellow
	thm.xcolor3 = green
end

for i = 0, 15 do
	style['color' .. i] = {common.color(thm['xcolor' .. i])}
end

style.gitdiff_padding = 4

style.background = { common.color(bg) }
style.background2 = { common.color(bg) }
style.background3 = style.color9
style.text = { common.color(fg) }
style.caret = style.color4
style.accent = style.color3
style.dim = style.color10
style.divider = { common.color "#242223" }
style.selection = style.color10
style.line_number = style.color11
style.line_number2 = { common.color(fg) }
style.line_highlight = style.color8
style.scrollbar = style.color10
style.scrollbar2 = style.color11

style.syntax["normal"] = { common.color(fg) }
style.syntax["symbol"] = { common.color(fg) }
style.syntax["comment"] = style.color11
style.syntax["keyword"] = { common.color(thm.xcolor5) }
style.syntax["keyword2"] = { common.color(thm.xcolor6) }
style.syntax["number"] = style.color1
style.syntax["literal"] = style.color2
style.syntax["string"] = { common.color(thm.xcolor2) }
style.syntax["operator"] = { common.color(thm.xcolor3) }
style.syntax["function"] = { common.color(thm.xcolor4) }

style.gitdiff_addition = {common.color(thm.xcolor2)}
style.gitdiff_modification = {common.color(thm.xcolor4)}
style.gitdiff_deletion = {common.color(thm.xcolor1)}
style.gitdiff_width = 2

style.gitstatus_addition = style.gitdiff_addition
style.gitstatus_modification = style.gitdiff_modification
style.gitstatus_deletion = style.gitdiff_deletion

style.lint = {
	info = style.color4,
	hint = style.color7,
	warning = style.color3,
	error = style.color1
}
