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
nimap('leader>z', '<Cmd>noh<CR>') -- Remove highlights with \z
nimap('<C-s>', '<Cmd>w<CR>') -- Save
nimap('<C-z>', '<Cmd>u<CR>') -- Undo
nimap('<C-x>', '<Cmd>redo<CR>') -- Redo

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

-- Completions
local t = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
	local col = vim.fn.col('.') - 1
	if col == 0 or vim.fn.getline '.':sub(col, col):match '%s' then
		return true
	else
		return false
	end
end

_G.tab_complete = function()
	if vim.fn.pumvisible() == 1 then
		return t '<C-n>'
	elseif vim.fn.call('vsnip#available', {1}) == 1 then
		return t '<Plug>(vsnip-expand-or-jump)'
	elseif check_back_space() then
		return t '<Tab>'
	else
		return vim.fn['compe#complete']()
	end
end

_G.s_tab_complete = function()
	if vim.fn.pumvisible() == 1 then
		return t '<C-p>'
	elseif vim.fn.call('vsnip#jumpable', {-1}) == 1 then
		return t '<Plug>(vsnip-jump-prev)'
	else
		-- If <S-Tab> is not working in your terminal, change it to <C-h>
		return t '<S-Tab>'
	end
end

map('i', '<Tab>', 'v:lua.tab_complete()', {expr = true})
map('s', '<Tab>', 'v:lua.tab_complete()', {expr = true})
map('i', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
map('s', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})

