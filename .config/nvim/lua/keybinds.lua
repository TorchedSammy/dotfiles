function map(mode, lhs, rhs, opts)
	local options = {
		noremap = true,
		silent = true
	}

	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

function nimap(lhs, rhs, opts)
	map('n', lhs, rhs, opts)
	map('i', lhs, rhs, opts)
end

-- Editor
nimap('<C-s>', '<Cmd>silent w<CR>') -- Save
nimap('<C-z>', '<Cmd>u<CR>') -- Undo
map('s', '<C-z>', '<Cmd>u<CR>') -- Undo
nimap('<C-r>', '<Cmd>redo<CR>') -- Redo
nimap('<C-S-Up>', '<Cmd>m .-2<CR>') -- Move line up
nimap('<C-S-Down>', '<Cmd>m .+1<CR>') -- Move line down

map('v', '<RightMouse>', "y")
nimap('<RightMouse>', 'p')
map('v', '<S-RightMouse>', "p")

vim.cmd [[imap <silent><script><expr> <C-d> copilot#Accept("\<CR>")]]

-- Toggle a terminal buffer
_G.OpenTerm = function(name, side)
	local term = vim.api.nvim_eval(string.format('bufwinnr("%s")', name))
	local buf = vim.api.nvim_eval(string.format('bufexists("%s")', name))

	-- If the term is visible, close it
	if term > 0 then
		-- If it's a side terminal
		if side then
			vim.cmd(tostring(term) .. 'wincmd c')
		else
			vim.cmd 'e #'
		end
	elseif buf > 0 then -- if current buffer isnt term
		if side then vim.cmd 'vsplit' end
		vim.cmd('b ' .. name)
	else -- if term doesnt exist
		if side then vim.cmd 'vsplit' end
		vim.cmd 'term'
		vim.bo.buflisted = false
		vim.wo.foldcolumn = '1' -- set left padding basically
		vim.cmd('f ' .. name)
	end
end

map('n', '<M-`>', '<Cmd>:call v:lua.OpenTerm("TerminalSide", v:true)<CR>') -- Toggle a side terminal
map('t', '<M-`>', '<C-\\><C-n>:call v:lua.OpenTerm("TerminalSide", v:true)<CR>') -- Map in terminal mode
map('n', '<M-CR>', '<Cmd>:call v:lua.OpenTerm("Terminal", v:false)<CR>')
map('n', '<M-CR>', '<C-\\><C-n>:call v:lua.OpenTerm("Terminal", v:false)<CR>')
map('t', '<Esc><Esc>', '<C-\\><C-n>')

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

-- Lspsaga
nimap('<C-e>', '<Cmd>Lspsaga hover_doc<CR>')
nimap('<C-g>', '<Cmd>Lspsaga rename<CR>')
map('n', '[e', '<Cmd>Lspsaga diagnostic_jump_next<CR>')
map('n', ']e', '<Cmd>Lspsaga diagnostic_jump_prev<CR>')

-- Telescope
nimap('<C-t>', [[<Cmd>:lua require 'telescope.builtin'.lsp_code_actions(require 'telescope.themes'.get_cursor{})<CR>]])
map('v', '<C-t>', [[<Cmd>:lua require 'telescope.builtin'.lsp_range_code_actions(require 'telescope.themes'.get_cursor{})<CR>]])
map('n', '<leader>ff', '<Cmd>Telescope find_files<CR>')
map('n', '<leader>gf', '<Cmd>Telescope git_files<CR>')
map('n', '<leader>rf', '<Cmd>Telescope oldfiles<CR>') -- recent files
map('n', '<leader>hl', '<Cmd>Telescope highlights<CR>')

map('n', '<C-k>', '<Cmd>Telescope keymaps<CR>') -- look at keybinds
map('n', '<C-f>', '<Cmd>Telescope current_buffer_fuzzy_find<CR>')
