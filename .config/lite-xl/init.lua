local core = require 'core'
local config = require 'core.config'
local style = require 'core.style'
local RootView = require 'core.rootview'
local StatusView = require 'core.statusview'
local DocView = require 'core.docview'

local fontconfig = require 'plugins.fontconfig'
local lspconfig = require 'plugins.lsp.config'
local lspkind = require 'plugins.lspkind'

config.ignore_files = {'^%.git$'}
local function ignoreExt(...)
	local exts = {...}
	for i in ipairs(exts) do
		table.insert(config.ignore_files, '[%w-.]+.' .. exts[i])
	end
end
ignoreExt('png')
fontconfig.use_blocking {
	font = {
		group = {
			'SF Pro Display:style=Regular',
			'VictorMono Nerd Font Mono:style=Medium',
			'Segoe UI Emoji'
		},
		size = 12 * SCALE
	},
	code_font = {
		group = {
			'VictorMono Nerd Font Mono:style=Medium',
			'Segoe UI Emoji'
		},
		size = 12 * SCALE
	}
}

lspkind.setup {}
core.reload_module 'colors.awesomewm'

-- funny issue: https://safe.kashima.moe/3q6397s0kxcx.png
-- that blue line is literally the minimap since it apparently draws itself
-- as a scrollbar on docview, and the command view is a docview ????
-- doing this as a solution works
core.command_view.draw_scrollbar = function() end

-- customize fonts:
-- style.font = renderer.font.load(DATADIR .. '/fonts/FiraSans-Regular.ttf', 14 * SCALE)
-- style.code_font = renderer.font.load(DATADIR .. '/fonts/.ttf', 10 * SCALE)
-- font names used by lite:
-- style.font          : user interface
-- style.big_font      : big text in welcome screen
-- style.icon_font     : icons
-- style.icon_big_font : toolbar icons
-- style.code_font     : code

config.tab_type = 'hard'
config.indent_size = 4
config.scroll_past_end = false
config.plugins.toolbarview = false
config.plugins.trimwhitespace = true
config.plugins.lsp.stop_unneeded_servers = false
config.lint.lens_style = 'solid'

local rv_draw = RootView.draw
local time = ''
local date = ''
local time_width = 0
local time_height = 0
local date_width = 0

core.add_thread(function()
	while true do
		time = os.date '%I:%M %p'
		date = os.date '%a, %d %b'
		time_width = style.code_font:get_width(time)
		date_width = style.code_font:get_width(date)
		time_height = style.code_font:get_height()
		coroutine.yield(1)
	end
end)

function RootView:draw(...)
	rv_draw(self, ...)
	if core.active_view == core.command_view then return end
	renderer.draw_text(style.code_font, date, self.size.x - date_width - 25, self.size.y - (time_height * 2) - 60, style.text)
	renderer.draw_text(style.code_font, time, self.size.x - time_width - 25, self.size.y - time_height - 60, style.text)
end

local bigCodeFont = style.code_font:copy((12 * 1.6) * SCALE)

function StatusView:get_items()
	if getmetatable(core.active_view) == DocView then
		local dv = core.active_view
		local line, col = dv.doc:get_selection()
		local dirty = dv.doc:is_dirty()
		local indent_type, indent_size, indent_confirmed = dv.doc:get_indent_info()
		local indent_label = (indent_type == 'hard') and 'Tabs' or 'Spaces'
		local indent_size_str = tostring(indent_size) .. (indent_confirmed and '' or '*')
		local indent = indent_size_str .. ' ' .. indent_label

		return {
			dirty and style.accent or style.text, style.icon_font, 'f',
			style.dim, style.font, self.separator2, style.text,
			dv.doc.filename and style.text or style.dim, dv.doc:get_name(),
		}, {
			style.text, indent,
			style.dim, self.separator2, style.text,
			line, ':', col,
			style.dim, self.separator2, style.text,
			string.format('%.f%%', line / #dv.doc.lines * 100),
			style.dim, self.separator2, style.text,
			#dv.doc.lines, ' lines', style.dim,
			style.dim, self.separator2, style.text,
			style.color1, bigCodeFont, '',
			style.text, style.font, ''
		}
	end

	return {}, {
	--[[
		style.icon_font, 'g',
		style.font, style.dim, self.separator2,
		#core.docs, style.text, ' / ',
		#core.project_files, ' files'
	]]--
	}
end

lspconfig.gopls.setup {}
lspconfig.sumneko_lua.setup {
	command = {
		HOME .. '/.local/share/lite-xl/lsp/lua-language-server/bin/lua-language-server',
		'-E',
		HOME .. '/.local/share/lite-xl/lsp/lua-language-server/main.lua',
	}
}
