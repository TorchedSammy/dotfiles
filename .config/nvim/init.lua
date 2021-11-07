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
vim.o.completeopt = 'menu,menuone,noselect'
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 0
vim.o.splitright = true
vim.wo.number = true
vim.cmd 'set ci'
vim.cmd 'set undofile'

-- LSP
local lua_settings = {
	Lua = {
		runtime = {
			  -- LuaJIT in the case of Neovim
			  version = 'LuaJIT',
			  path = vim.split(package.path, ';'),
		},
		diagnostics = {
			-- Get the language server to recognize the `vim` global
			globals = {'vim'},
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

	return {
		capabilities = capabilities,
	}
end

local function setupServers()
	require 'lspinstall'.setup()
	local servers = require 'lspinstall'.installed_servers()
	for _, server in pairs(servers) do
		local conf = makeConf()

		if server == 'lua' then
				conf.settings = lua_settings
				conf.root_dir = function(fname)
					if fname:match 'lush_theme' ~= nil then return nil end
					local util = require 'lspconfig.util'
					return util.find_git_ancestor(fname) or util.path.dirname(fname)
				end
		end
		require 'lspconfig'[server].setup(conf)
	end
end

setupServers()

require 'lspinstall'.post_install_hook = function()
	setupServers() -- reload installed servers
	vim.cmd('bufdo e') -- this triggers the FileType autocmd that starts the server
end

