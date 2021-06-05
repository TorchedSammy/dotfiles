require 'plugins'
require 'theme'

function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Neovim stuff
vim.cmd 'set number'
--vim.cmd 'colorscheme dim'
vim.cmd 'set noet ci pi sts=0 sw=4 ts=4'

-- Nvim-tree
vim.g.nvim_tree_width = 24
vim.g.nvim_tree_ignore = { '.git', 'node_modules', '.cache' }
vim.g.nvim_tree_auto_open = 1
vim.g.nvim_tree_auto_close = 1
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_git_hl = 1
vim.g.nvim_tree_show_icons = {
	git = 1,
	folders = 1,
	files = 1,
}

-- Barbar
map('n', '<A-z>', [[ <Cmd>BufferPrevious<CR> ]], nil)
map('n', '<A-x>', [[ <Cmd>BufferNext<CR> ]], nil)
map('n', '<A-c>', [[ <Cmd>BufferClose<CR> ]], nil)

-- Colors
--[[vim.cmd 'hi NvimTreeVertSplit cterm=none ctermfg=0 ctermbg=0'
vim.cmd 'hi EndOfBuffer cterm=none ctermfg=0 ctermbg=0'
vim.cmd 'hi SignColumn cterm=none ctermfg=0 ctermbg=0'

vim.cmd 'hi GitSignsAdd ctermfg=2'
vim.cmd 'hi GitSignsRemove ctermfg=1'
vim.cmd 'hi GitSignsChange ctermfg=4'
]]--
