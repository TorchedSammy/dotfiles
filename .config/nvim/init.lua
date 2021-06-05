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
vim.o.mouse = 'a'
vim.o.expandtab = false
vim.o.preserveindent = true
vim.o.softtabstop = 0
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.wrap = false
vim.o.showmode = false
vim.cmd 'set number'
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
-- Editor (bindings from ordinary text editors)
nimap('<C-s>', '<Cmd>w<CR>') -- Save
nimap('<C-z>', '<Cmd>u<CR>') -- Undo
nimap('<C-r>', '<Cmd>r<CR>') -- Redo

-- NvimTree
map('n', '<C-n>', '<Cmd>NvimTreeToggle<CR>')
map('n', '<leader>r', '<Cmd>NvimTreeRefresh<CR>')

-- Barbar
map('n', '<A-z>', '<Cmd>BufferPrevious<CR>')
map('n', '<A-x>', '<Cmd>BufferNext<CR>')
map('n', '<A-c>', '<Cmd>BufferClose<CR>')
map('n', '<A-S-c>', '<Cmd>BufferClose!<CR>')
-- }}}
