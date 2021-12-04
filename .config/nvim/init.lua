require 'plugins'
require 'theme'
require 'keybinds'

-- Neovim stuff
vim.o.hidden = true
vim.o.cursorline = true
vim.o.preserveindent = true
vim.o.termguicolors = true
vim.o.wrap = false
vim.o.ruler = false
vim.o.showmode = false
vim.o.expandtab = false
vim.o.mouse = 'a'
vim.o.completeopt = 'menu,menuone,noinsert'
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 0
vim.o.splitright = true
vim.wo.number = true
vim.opt.ci = true
vim.opt.undofile = true
vim.opt.guicursor:append('i:blinkwait700-blinkon400-blinkoff250') -- set insert mode cursor to blink

vim.cmd 'autocmd TermOpen * setlocal nonumber norelativenumber foldcolumn=3' -- remove line numbers from terminal

-- LSP
local lua_settings = {
	Lua = {
		runtime = {
			  -- LuaJIT in the case of Neovim
			  version = 'LuaJIT',
			  path = vim.split(package.path, ';'),
		},
		diagnostics = {
			globals = {
				'awesome',
				'client',
				'screen',
				'root',
				'vim',
				'hilbish',
				'alias',
				'appendPath',
				'prependPath'
			},
		},
		workspace = {
		  -- Make the server aware of Neovim runtime files
			library = {
				[vim.fn.expand('$VIMRUNTIME/lua')] = true,
				[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
			},
		},
	},
}

local function makeConf()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require 'cmp_nvim_lsp'.update_capabilities(capabilities)

	return {capabilities = capabilities}
end

local lspinst = require("nvim-lsp-installer")

lspinst.on_server_ready(function(server)
	local opts = makeConf()

	if server.name == "sumneko_lua" then
		opts.settings = lua_settings
		opts.root_dir = function(fname)
			local util = require 'lspconfig.util'
			return util.find_git_ancestor(fname) or util.path.dirname(fname)
		end
	end

	server:setup(opts)
end)

