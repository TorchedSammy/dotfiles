local core = require 'core'
local style = require 'core.style'
local common = require 'core.common'
local View = require 'core.view'
local DocView = require 'core.docview'
local StatusView = require 'core.statusview'
local TreeView = require 'plugins.treeview'
getmetatable(_G).__index = function(t, k) return rawget(t, k) end

local oldPackagePath = package.path
package.path = package.path .. ';' .. os.getenv 'HOME' .. '/.config/awesome/?.lua'

local awesomeDir = '~/.config/awesome'
local awmThemename = dofile((awesomeDir .. '/conf/settings.lua'):gsub('~', os.getenv 'HOME')).theme
local themePath = awesomeDir .. '/themes/' .. awmThemename .. '.lua'
local thm = dofile(themePath:gsub('~', os.getenv('HOME')))
local bg = thm.xbackground
local fg = thm.xforeground

package.path = oldPackagePath

if thm.name == 'horizon' then
	local green = thm.xcolor2
	local yellow = thm.xcolor3
	thm.xcolor2 = yellow
	thm.xcolor3 = green
end

for i = 0, 15 do
	style['color' .. i] = {common.color(thm['xcolor' .. i])}
end

style.syntax = {
	normal = {common.color(fg)},
	symbol = {common.color(fg)},
	comment = style.color11,
	keyword2 = style.color2,
	literal = style.color1,

	attribute = style.color3,
	boolean = style.color1,
	character = style.color2,
	conditional = style.color3,
	['conditional.ternary'] = style.color6,
	constant = style.color1,
	['constant.builtin'] = style.color1,
	define = style.color5,
	error = style.color1,
	exception = style.color5,
	include = style.color6,
	field = style.color3,
	float = style.color1,
	['function'] = style.color4,
	['function.call'] = style.color4,
	['function.builtin'] = style.color6,
	['function.macro'] = style.color6,
	--include = style.
	keyword = style.color5,
	['keyword.function'] = style.color5,
	['keyword.return'] = style.color14,
	['keyword.operator'] = style.color6,
	label = style.color14,
	method = style.color4,
	['method.call'] = style.color4,
	namespace = style.color5,
	number = style.color1,
	operator = style.color4,
	parameter = style.color14,
	preproc = style.color1,
	property = style.color6,
	['punctuation.delimiter'] = style.color14,
	['punctuation.bracket'] = {common.color(fg)},
	['punctuation.special'] = style.color3,
	['repeat'] = style.color6,
	string = style.color2,
	storageclass = style.color14,
	['text.diff.add'] = style.color2,
	['text.diff.delete'] = style.color1,
	type = style.color6,
	['type.builtin'] = style.color6,
	['type.definition'] = style.color14,
	['type.qualifier'] = style.color5,
	variable = {common.color(fg)},
	['variable.builtin'] = style.color5
}

-- UI colors
style.background = style.color15
style.background2 = style.color8
style.background3 = {common.color(bg)}
style.text = { common.color(fg) }
style.caret = style.color4
style.accent = style.color14
style.dim = style.color10
style.divider = style.color8
style.selection = style.color10
style.line_number = style.color11
style.line_number2 = style.color14
style.line_highlight = style.color9
style.scrollbar = style.color10
style.scrollbar2 = style.color11

local oldDrawBackground = View.draw_background
function TreeView:draw_background()
	oldDrawBackground(self, {common.color(bg)})
end

style.minimap_background = {common.color(bg)}
style.divider_size = 0

style.error = style.color1
style.good = style.color2
style.warn = style.color3
style.modified = style.color4

style.log.INFO  = { icon = 'i', color = style.text }
style.log.WARN  = { icon = '!', color = style.warn }
style.log.ERROR = { icon = '!', color = style.error }

style.caret_width = common.round(1.2 * SCALE)
style.gitdiff_addition = style.color2
style.gitdiff_modification = style.color4
style.gitdiff_deletion = style.color1
style.gitdiff_width = 2
style.gitdiff_padding = 4

style.gitstatus_addition = style.gitdiff_addition
style.gitstatus_modification = style.gitdiff_modification
style.gitstatus_deletion = style.gitdiff_deletion

style.lint = {
	info = style.color14,
	hint = style.color4,
	warning = style.color3,
	error = style.color1
}

style.visu = {
	bars = style.color7
}
