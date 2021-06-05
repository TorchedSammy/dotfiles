local colors = require 'themecolor'

-- taken from https://github.com/norcalli/nvim-base16.lua/blob/master/lua/base16.lua
local function highlight(group, guifg, guibg, ctermfg, ctermbg, attr, guisp)
	local parts = {group}
	local gfg = guifg and "guifg="..guifg or 'guifg=none'
	local gbg = guibg and "guibg="..guibg or 'guibg=none'
	local ctfg = ctermfg and "ctermfg="..ctermfg or 'ctermfg=none'
	local ctbg = ctermbg and "ctermbg="..ctermbg or 'ctermbg=none'
	local attrs = attr and 'gui=' .. attr .. ' cterm=' .. attr or 'gui=none cterm=none'
	local gsp = guisp and "guisp=#"..guisp or 'guisp=none'

	-- nvim.ex.highlight(parts)
	vim.api.nvim_command('highlight '..table.concat({group, gfg, gbg, ctfg, ctbg, gsp, attrs}, ' '))
end

local highlights = {
	-- Basic Syntax Colors
	NonText = {ctfg = 12},
	SpellBad = {ctfg = 1, attr = 'underlineitalic'},
	SpellCap = {ctfg = 4, attr = 'underlineitalic'},
	SpellLocal = {ctfg = 4, attr = 'italic'},
	SpellRare = {ctfg = 14, attr = 'italic'},
	MatchParen = {ctbg = 8},
	Constant = {ctfg = 2},
	Special = {ctfg = 5},
	Identifier = {ctfg = 4},
	Statement = {ctfg = 3},
	PreProc = {ctfg = 5},
	Type = {ctfg = 4},
	Underlined = {ctfg = 6, attr = 'underline'},
	Ignore = {ctfg = 15},
	Error = {ctfg = 9, attr = 'underlineitalic'},
	Todo = {ctfg = 0, ctbg = 8, attr = 'underline'},
	Comment = {ctfg = 8, attr = 'italic'},

	-- Editor Elements
	ErrorMsg = {ctfg = 1, attr = 'underlineitalic'},
	CursorColumn = {ctbg = 8},
	CursorLine = {attr = 'bold'},
	CursorLineNr = {ctfg = 15},
	MoreMsg = {ctfg = 6},
	ModeMsg = {ctfg = 5, attr = 'bold'},
	Question = {ctfg = 2},
	WarningMsg = {ctfg = 3, attr = 'underlineitalic'},
	Title = {ctfg = 5},
	Conceal = {ctbg = 7, ctfg = 7},
	IncSearch = {ctbg = 8},
	PmenuSbar = {ctbg = 8},
	PmenuThumb = {ctbg = 0},
	WildMenu = {ctbg = 11},
	Tabline = {ctfg = 0, ctbg = 7, attr = 'underline'},
	TablineSel = {attr = 'bold'},
	TablineFill = {attr = 'reverse'},
	Directory = {ctfg = 4},
	SpecialKey = {ctfg = 4},
	TermCursor = {attr = 'reverse'},
	EndOfBuffer = {ctfg = 0, ctbg = 0},
	Visual = {attr = 'reverse'},
	ColorColumn = {ctfg = 7, ctbg = 8},
	Folded = {ctfg = 7, ctbg = 8},
	FoldColumn = {ctfg = 7, ctbg = 8},
	Pmenu = {ctfg = 15, ctbg = 8},
	PmenuSel = {ctfg = 8, ctbg = 15},
	StatusLine = {ctfg = 15, ctbg = 8, attr = 'bold'},
	StatusLineNC = {ctfg = 7, ctbg = 8},
	SignColumn = {},

	-- NvimTree
	NvimTreeVertSplit = {gfg = 'black', gbg = 'black', ctfg = 0, ctbg = 0, attr = 'none'},

	-- GitSigns.nvim
	GitSignsAdd = {ctfg = 14},
	GitSignsDelete = {ctfg = 1},
	GitSignsChange = {ctfg = 3}
}

for group, styles in pairs(highlights) do
    highlight(group, styles.gfg, styles.gbg, styles.ctfg, styles.ctbg, styles.attr)
end