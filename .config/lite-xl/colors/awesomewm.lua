local style = require "core.style"
local common = require "core.common"

local awesomeDir = '~/.config/awesome'
local themename = dofile((awesomeDir .. '/conf/settings.lua'):gsub('~', os.getenv 'HOME')).theme
local themePath = awesomeDir .. '/themes/colors/' .. themename .. '.lua'
local thm = dofile(themePath:gsub('~', os.getenv('HOME')))
local bg = thm.xbackground
local fg = thm.xforeground

for i = 0, 15 do
	style['color' .. i] = {common.color(thm['xcolor' .. i])}
end
style.gitdiff_padding = 4

style.background = { common.color(bg) }
style.background2 = { common.color(bg) }
style.background3 = style.color9
style.text = { common.color(fg) }
style.caret = { common.color "#61efce" }
style.accent = { common.color "#ffd152" }
style.dim = { common.color "#615d5f" }
style.divider = { common.color "#242223" }
style.selection = style.color10
style.line_number = style.color11
style.line_number2 = { common.color(fg) }
style.line_highlight = style.color8
style.scrollbar = { common.color "#454344" }
style.scrollbar2 = { common.color "#524F50" }

style.syntax["normal"] = { common.color(fg) }
style.syntax["symbol"] = { common.color(fg) }
style.syntax["comment"] = style.color11
style.syntax["keyword"] = { common.color(thm.xcolor5) }
style.syntax["keyword2"] = { common.color(thm.xcolor5) }
style.syntax["number"] = { common.color "#ffd152" }
style.syntax["literal"] = { common.color "#ffd152" }
style.syntax["string"] = { common.color(thm.xcolor2) }
style.syntax["operator"] = { common.color(thm.xcolor3) }
style.syntax["function"] = { common.color(thm.xcolor4) }

style.gitdiff_addition = {common.color(thm.xcolor2)}
style.gitdiff_modification = {common.color(thm.xcolor4)}
style.gitdiff_deletion = {common.color(thm.xcolor1)}

style.gitstatus_addition = style.gitdiff_addition
style.gitstatus_modification = style.gitdiff_modification
style.gitstatus_deletion = style.gitdiff_deletion
