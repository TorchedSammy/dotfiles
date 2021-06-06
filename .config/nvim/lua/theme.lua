local tc = require 'themecolor'

-- taken from https://github.com/norcalli/nvim-base16.lua/blob/master/lua/base16.lua
local function highlight(group, guifg, guibg, ctermfg, ctermbg, attr, guisp)
	local parts = {group}
	local gfg = guifg and "guifg=#"..guifg or 'guifg=none'
	local gbg = guibg and "guibg=#"..guibg or 'guibg=none'
	local ctfg = ctermfg and "ctermfg="..ctermfg or 'ctermfg=none'
	local ctbg = ctermbg and "ctermbg="..ctermbg or 'ctermbg=none'
	local attrs = attr and 'gui=' .. attr .. ' cterm=' .. attr or 'gui=none cterm=none'
	local gsp = guisp and "guisp=#"..guisp or 'guisp=none'

	vim.api.nvim_command('highlight '..table.concat({group, gfg, gbg, ctfg, ctbg, gsp, attrs}, ' '))
end

local highlights = {
	-- Basic Syntax Colors
	NonText = {gfg = tc.gui12, ctfg = 12},
	SpellBad = {gfg = tc.gui1, ctfg = 1, attr = 'underlineitalic'},
	SpellCap = {gfg = tc.gui4, ctfg = 4, attr = 'underlineitalic'},
	SpellLocal = {gfg = tc.gui4, ctfg = 4, attr = 'italic'},
	SpellRare = {gfg = tc.gui14, ctfg = 14, attr = 'italic'},
	MatchParen = {gbg = tc.gui9, ctbg = 8},
	Constant = {gfg = tc.gui2, ctfg = 2},
	Special = {gfg = tc.gui5, ctfg = 5},
	Identifier = {gfg = tc.gui4, ctfg = 4},
	Statement = {gfg = tc.gui3, ctfg = 3},
	PreProc = {gfg = tc.gui5, ctfg = 5},
	Type = {gfg = tc.gui4, ctfg = 4},
	Underlined = {gfg = tc.gui6, ctfg = 6, attr = 'underline'},
	Ignore = {gfg = tc.fg, ctfg = 15},
	Error = {gfg = tc.gui9, ctfg = 9, attr = 'underlineitalic'},
	Todo = {gfg = tc.bg, gbg = tc.gui8, ctfg = 0, ctbg = 8, attr = 'underline'},
	Comment = {gfg = tc.gui8, ctfg = 8, attr = 'italic'},

	-- Editor Elements
	ErrorMsg = {gfg = tc.gui1, ctfg = 1, attr = 'underlineitalic'},
	CursorColumn = {gbg = tc.gui8, ctbg = 8},
	CursorLine = {attr = 'bold'},
	CursorLineNr = {gfg = tc.fgli, ctfg = 15},
	LineNr = {gfg = tc.gui8, ctfg = 11},
	MoreMsg = {gfg = tc.gui6, ctfg = 6},
	ModeMsg = {gfg = tc.gui5, ctfg = 5, attr = 'bold'},
	Question = {gfg = tc.gui2, ctfg = 2},
	WarningMsg = {gfg = tc.gui3, ctfg = 3, attr = 'underlineitalic'},
	Title = {gfg = tc.gui5, ctfg = 5},
	Conceal = {gfg = tc.bg, gbg = tc.bg, ctbg = 7, ctfg = 7},
	Search = {gbg = tc.bgvli, ctbg = 11},
	IncSearch = {gbg = tc.bgvli, ctbg = 8},
	PmenuSbar = {gbg = tc.gui8, ctbg = 8},
	PmenuThumb = {gbg = tc.bg, ctbg = 0},
	WildMenu = {gbg = tc.bgvli, ctbg = 11},
	Tabline = {gfg = tc.bg, gbg = tc.fg, ctfg = 0, ctbg = 7, attr = 'underline'},
	TablineSel = {attr = 'bold'},
	TablineFill = {attr = 'reverse'},
	Directory = {gfg = tc.gui4, ctfg = 4},
	SpecialKey = {gfg = tc.gui4, ctfg = 4},
	TermCursor = {attr = 'reverse'},
	EndOfBuffer = {gfg = tc.bg, gbg = tc.bg, ctfg = 0, ctbg = 0},
	Visual = {gbg = tc.bgvli},
	ColorColumn = {gfg = tc.fg, gbg = tc.gui8, ctfg = 7, ctbg = 8},
	Folded = {gfg = tc.fg, gbg = tc.gui8, ctfg = 7, ctbg = 8},
	FoldColumn = {gfg = tc.fg, gbg = tc.gui8, ctfg = 7, ctbg = 8},
	Pmenu = {gfg = tc.fgli, gbg = tc.gui8, ctfg = 15, ctbg = 8},
	PmenuSel = {gfg = tc.gui8, gbg = tc.fgli, ctfg = 8, ctbg = 15},
	StatusLine = {gfg = tc.fgli, gbg = tc.gui8, ctfg = 15, ctbg = 8, attr = 'bold'},
	StatusLineNC = {gfg = tc.fg, gbg = tc.gui8, ctfg = 7, ctbg = 8},
	SignColumn = {},

	-- NvimTree
	NvimTreeEndOfBuffer = {gfg = tc.bg, gbg = tc.bg, ctfg = 0, ctbg = 0},
	NvimTreeVertSplit = {gfg = tc.bg, gbg = tc.bg, ctfg = 0, ctbg = 0},
	NvimTreeNormal = {gfg = tc.fgli, gbg = tc.bg, ctfg = 7, ctbg = 0},
	NvimTreeRootFolder = {},
	NvimTreeGitDirty = {gfg = tc.gui4, ctfg = 4},
	NvimTreeGitNew = {gfg = tc.gui2, ctfg = 2, attr = 'italic'},
	NvimTreeGitRenamed = {gfg = tc.gui6, ctfg = 6, attr = 'italic'},
	NvimTreeGitStaged = {gfg = tc.gui2, ctfg = 2},

	-- GitSigns.nvim
	GitSignsAdd = {gfg = tc.gui2, ctfg = 2},
	GitSignsDelete = {gfg = tc.gui1, ctfg = 1},
	GitSignsChange = {gfg = tc.gui4, ctfg = 4},

	-- Scrollview
	ScrollView = {gbg = tc.gui8, ctbg = 8}
}

for group, styles in pairs(highlights) do
    highlight(group, styles.gfg, styles.gbg, styles.ctfg, styles.ctbg, styles.attr)
end
