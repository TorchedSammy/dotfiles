require 'plugins'
require 'theme'

function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Neovim stuff
vim.cmd 'set number'
vim.o.hidden = true
vim.o.mouse = 'a'
vim.o.noexpandtab = true
vim.o.preserveindent = true
vim.o.softtabstop = 0
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.cmd 'set ci'

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

-- {{{ Keybinds
-- NvimTree
map('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>')
map('n', '<leader>r', '<Cmd>NvimTreeRefresh<CR>')

-- Barbar
map('n', '<A-z>', '<Cmd>BufferPrevious<CR>')
map('n', '<A-x>', '<Cmd>BufferNext<CR>')
map('n', '<A-c>', '<Cmd>BufferClose<CR>')
map('n', '<A-S-c>', '<Cmd>BufferClose!<CR>')
-- }}}

-- Colors
--[[vim.cmd 'hi NvimTreeVertSplit cterm=none ctermfg=0 ctermbg=0'
vim.cmd 'hi EndOfBuffer cterm=none ctermfg=0 ctermbg=0'
vim.cmd 'hi SignColumn cterm=none ctermfg=0 ctermbg=0'

vim.cmd 'hi GitSignsAdd ctermfg=2'
vim.cmd 'hi GitSignsRemove ctermfg=1'
vim.cmd 'hi GitSignsChange ctermfg=4'
]]--
