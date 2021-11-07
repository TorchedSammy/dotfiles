function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function nimap(lhs, rhs, opts)
	map('n', lhs, rhs, opts)
	map('i', lhs, rhs, opts)
end

-- Editor
nimap('<leader>z', '<Cmd>noh<CR>') -- Remove highlights with \z
nimap('<C-s>', '<Cmd>w<CR>') -- Save
nimap('<C-z>', '<Cmd>u<CR>') -- Undo

nimap('<C-S-Up>', '<Cmd>m .-2<CR>')
nimap('<C-S-Down>', '<Cmd>m .+1<CR>')
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

-- Trouble
map('n', '<C-x>', '<Cmd>TroubleToggle<CR>')

