local core = require 'core'
local config = require 'core.config'
local keymap = require 'core.keymap'
local style = require 'core.style'
local StatusView = require 'core.statusview'
local DocView = require 'core.docview'
local CommandView = require 'core.commandview'
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
local italicFont = fontconfig.load_group_blocking({
	'VictorMono Nerd Font Mono:style=Medium Italic',
	'Segoe UI Emoji'
	},
	12 * SCALE
)

style.syntax_fonts = {
	comment = italicFont,
	keyword2 = italicFont,
	type_builtin = italicFont,
	error = italicFont
}
for _, font in pairs(style.syntax_fonts) do
	font:set_tab_size(4)
end

lspkind.setup {
	fontName = 'VictorMono Nerd Font Mono:style=Medium'
}
core.reload_module 'colors.awesomewm'

config.tab_type = 'hard'
config.indent_size = 4
config.scroll_past_end = false
config.plugins.toolbarview = false
--config.plugins.trimwhitespace = true
config.lint.lens_style = 'solid'
config.plugins.lsp.stop_unneeded_servers = false
config.plugins.plugin_manager.lpm_binary_path = HOME .. '/Downloads/lite-xl-plugin-manager/lpm'
config.plugins.scale.mode = 'ui'
config.plugins.miq.lpm_prefix = HOME .. '/Downloads/lite-xl-plugin-manager/'
config.plugins.miq.debug = true
config.plugins.miq.plugins = {
	-- let miq manage itself from my dev dir
	'~/Files/Projects/Miq',
	'TorchedSammy/Feathertime',
	'TorchedSammy/Litepresence',
	'TorchedSammy/Lazulight.lxl',
	'TorchedSammy/lite-xl-gitdiff-highlight',
	'lite-xl/lite-xl-lsp',
	'TorchedSammy/lite-xl-lspkind',
	-- others
	'anthonyaxenov/lite-xl-ignore-syntax',
	'juliardi/lite-xl-treeview-menu-extender',
	'liquidev/lintplus'
}

local bigCodeFont = style.code_font:copy((16 * 1.6) * SCALE)
if not core.status_view:get_item 'icon:heart' then
	core.status_view:add_item {
		predicate = function()
			return core.active_view:is(DocView) and not core.active_view:is(CommandView)
		end,
		name = 'icon:heart',
		alignment = StatusView.Item.RIGHT,
		get_item = function()
			return {
				style.color1, bigCodeFont, ''
			}
		end,
		tooltip = '<3'
	}
end
core.status_view:hide_items {'doc:line-ending', 'command:files'}
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
					'/usr/share/hilbish/emmyLuaDocs',
					'/usr/share/hilbish/libs'
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
