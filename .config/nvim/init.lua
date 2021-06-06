require 'plugins'
require 'theme'

function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function nimap(lhs, rhs, opts)
	map('n', lhs, rhs, opts)
	map('i', lhs, rhs, opts)
end

-- Neovim stuff
vim.o.hidden = true
vim.o.undofile = true
vim.o.cursorline = true
vim.o.termguicolors = true
vim.o.preserveindent = true
vim.o.wrap = false
vim.o.ruler = false
vim.o.showmode = false
vim.o.expandtab = false
vim.o.mouse = 'a'
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 0
vim.cmd 'set number'
vim.cmd 'set ci'

-- Nvim-tree
vim.g.nvim_tree_width = 24
vim.g.nvim_tree_ignore = {'.git', 'node_modules', '.cache'}
vim.g.nvim_tree_auto_open = 1
vim.g.nvim_tree_auto_close = 1
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_show_icons = {
	git = 1,
	folders = 1,
	files = 1,
}

-- {{{ Keybinds
-- Editor (bindings from ordinary text editors)
nimap('<C-s>', '<Cmd>w<CR>') -- Save
nimap('<C-z>', '<Cmd>u<CR>') -- Undo
nimap('<C-r>', '<Cmd>r<CR>') -- Redo
nimap('<C-S-Up>', '<Cmd>m .-2<CR>==')
nimap('<C-S-Down>', '<Cmd>m .+1<CR>==')
--map('v', '<C-S-Up>', '<Cmd>m \'>-2<CR>gv=gv')
--map('v', '<C-S-Down>', '<Cmd>m \'>+1<CR>gv=gv')

-- NvimTree
map('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>')
map('n', '<leader>r', '<Cmd>NvimTreeRefresh<CR>')

-- Barbar
map('n', '<A-z>', '<Cmd>BufferPrevious<CR>')
map('n', '<A-x>', '<Cmd>BufferNext<CR>')
map('n', '<A-c>', '<Cmd>BufferClose<CR>')
map('n', '<A-S-c>', '<Cmd>BufferClose!<CR>')
-- }}}

-- LSP
local function setupServers()
	require 'lspinstall'.setup()
	local servers = require 'lspinstall'.installed_servers()
	for _, server in pairs(servers) do
		local conf = {}
		if server == 'lua' then
			conf =  {
				settings = {
					Lua = {
						telemetry = {
							enable = false,
						},
						runtime = {
							path = vim.split(package.path, ';'),
						},
						diagnostics = {
							globals = {'vim'},
						},
						workspace = {
							library = {
								[vim.fn.expand('$VIMRUNTIME/lua')] = true,
								[vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
							},
						},
					},
				},
			}
		end
		require 'lspconfig'[server].setup(conf)
	end
end

setupServers()

require 'lspinstall'.post_install_hook = function()
	setupServers() -- reload installed servers
	vim.cmd('bufdo e') -- this triggers the FileType autocmd that starts the server
end