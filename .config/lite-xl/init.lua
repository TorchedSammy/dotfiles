require 'miq'

local core = require 'core'
local config = require 'core.config'
local command = require 'core.command'
local keymap = require 'core.keymap'
local style = require 'core.style'
local StatusView = require 'core.statusview'
local DocView = require 'core.docview'
local CommandView = require 'core.commandview'
local fontconfig = require 'plugins.fontconfig'
local lsp = require 'plugins.lsp'
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

local codefont = 'Monaspace Neon'
local codefontStyle = 'Regular'
local italicCodeFont = 'Monaspace Radon'
local codefontStyleItalic = 'Medium'
local fontSize = 14
local ligs = {
	ss01 = false,
--	ss03 = true,
--	ss05 = true,
--	ss06 = true,
	ss07 = true,
	ss08 = true,
	calt = true,
	dlig = true
}

fontconfig.use_blocking {
	font = {
		group = {
			'SF Pro Display:style=Regular',
			codefont .. ':style=' .. codefontStyle,
			'Segoe UI Emoji'
		},
		size = 16 * SCALE,
		ligatures = ligs
	},
	code_font = {
		group = {
			codefont .. ':style=' .. codefontStyle,
			'Segoe UI Emoji'
		},
		size = fontSize * SCALE,
		ligatures = ligs
	},
}
local italicFont = fontconfig.load_group_blocking({
	italicCodeFont .. ':style=' ..  codefontStyleItalic,
	'Segoe UI Emoji'
	},
	fontSize * SCALE
)

style.syntax_fonts = {
	comment = italicFont,
	keyword2 = italicFont,
	['type.builtin'] = italicFont,
	error = italicFont,
	['function.builtin'] = italicFont
}
for _, font in pairs(style.syntax_fonts) do
	font:set_tab_size(4)
end

lspkind.setup {
	fontName = codefont .. ':style=' .. codefontStyle
}

config.tab_type = 'hard'
config.indent_size = 4
config.scroll_past_end = false
config.plugins.toolbarview = false
--config.plugins.trimwhitespace = true
config.lint.lens_style = 'solid'
config.plugins.lsp.stop_unneeded_servers = false
config.plugins.scale.mode = 'ui'

local bigCodeFont = style.code_font:copy(16 * SCALE)
if not core.status_view:get_item 'icon:heart' then
	core.status_view:add_item {
		name = 'icon:heart',
		alignment = StatusView.Item.RIGHT,
		get_item = function()
			return {
				style.color1, bigCodeFont, '♥'
			}
		end,
		tooltip = '<3',
		separator = StatusView.separator2
	}
end
core.status_view:hide_items {'doc:line-ending', 'command:files', 'status:scm'}
core.status_view:move_item('doc:position', 3, StatusView.Item.RIGHT)

keymap.add_direct {
	['ctrl+shift+r'] = 'core:restart'
}

lspconfig.gopls.setup {}
lspconfig.sumneko_lua.setup {
	command = {
		HOME .. '/.local/share/lite-xl/lsp/lua-language-server/bin/lua-language-server',
		'-E',
		HOME .. '/.local/share/lite-xl/lsp/lua-language-server/main.lua',
	},
	settings = {
		Lua = {
			workspace = {
				library = {
					DATADIR,
					'/usr/local/share/hilbish/emmyLuaDocs',
					'/usr/local/share/hilbish/libs'
				}
			},
			diagnostics = {
				neededFileStatus = {
					['lowercase-global'] = 'None'
				}
			}
		}
	}
}

lsp.add_server {
	name = 'gleam',
	language = 'gleam',
	file_patterns = { '%.gleam' },
	command = { 'gleam', 'lsp' }
}

core.reload_module 'colors.awesomewm'
