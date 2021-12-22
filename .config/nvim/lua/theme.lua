local tc = require 'themecolor'

-- taken from https://github.com/norcalli/nvim-base16.lua/blob/master/lua/base16.lua
local function highlight(group, guifg, guibg, ctermfg, ctermbg, attr, guisp, force)
	local gfg = guifg and "guifg=#"..guifg or 'guifg=none'
	local gbg = guibg and "guibg=#"..guibg or 'guibg=none'
	local ctfg = ctermfg and "ctermfg="..ctermfg or 'ctermfg=none'
	local ctbg = ctermbg and "ctermbg="..ctermbg or 'ctermbg=none'
	local attrs = attr and 'gui=' .. attr .. ' cterm=' .. attr or 'gui=none cterm=none'
	local gsp = guisp and "guisp=#"..guisp or 'guisp=none'

	vim.api.nvim_command('hi' .. (force and '! ' or ' ')..table.concat({group, gfg, gbg, ctfg, ctbg, gsp, attrs}, ' '))
end

local highlights = {
	-- Basic Syntax Colors
	NonText = {gfg = tc.gui12, ctfg = 12},
	SpellBad = {gfg = tc.red, ctfg = 1, attr = 'underlineitalic'},
	SpellCap = {gfg = tc.blue, ctfg = 4, attr = 'underlineitalic'},
	SpellLocal = {gfg = tc.blue, ctfg = 4, attr = 'italic'},
	SpellRare = {gfg = tc.gui14, ctfg = 14, attr = 'italic'},
	MatchParen = {gbg = tc.gui9, ctbg = 8},
	Constant = {gfg = tc.green, ctfg = 2},
	Special = {gfg = tc.magenta, ctfg = 5},
	Identifier = {gfg = tc.blue, ctfg = 4},
	Statement = {gfg = tc.yellow, ctfg = 3},
	PreProc = {gfg = tc.magenta, ctfg = 5},
	Type = {gfg = tc.green, ctfg = 2},
	Underlined = {gfg = tc.cyan, ctfg = 6, attr = 'underline'},
	Ignore = {gfg = tc.fg, ctfg = 15},
	Error = {gfg = tc.gui9, ctfg = 9, attr = 'underlineitalic'},
	Todo = {gfg = tc.bg, gbg = tc.gui8, ctfg = 0, ctbg = 8, attr = 'underline'},
	Comment = {gfg = tc.gui8, ctfg = 8, attr = 'italic'},

	-- Treesitter :despair:
	TSAttribute = {gfg = tc.yellow, ctfg = 3, attr = 'bold'},
	TSAnnotation = {gfg = tc.yellow, ctfg = 3, attr = 'bold'}, -- basically decorators? ie @deprecated
	TSBoolean = {gfg = tc.red, ctfg = 1},
	TSCharacter = {gfg = tc.green, ctfg = 2}, -- a character lol
	TSComment = {gfg = tc.gui8, ctfg = 8, attr = 'italic'},
	TSConditional = {gfg = tc.yellow, ctfg = 3}, -- if, else
	TSConstant = {gfg = tc.red, ctfg = 1}, -- const variables; those in all caps
	TSConstBuiltin = {gfg = tc.yellow, ctfg = 3, attr = 'italic'}, -- already provided global consts, nil as example
	TSConstMacro = {gfg = tc.red, ctfg = 1, attr = 'italic'}, -- consts that are macros, like NULL in c
	TSConstructor = {gfg = tc.red, ctfg = 1},
	TSError = {gfg = tc.red, ctfg = 1, attr = 'italic'}, -- lsp errors
--	TSException = {}, -- TODO
	TSField = {gfg = tc.fg, ctfg = 7}, -- lua: tbl = {FIELD = 'thing'}, highlights FIELD
	TSFloat = {gfg = tc.red, ctfg = 5},
	TSFunction = {gfg = tc.blue, ctfg = 4}, -- function declaration and use
	TSFuncBuiltin = {gfg = tc.cyan, ctfg = 6, attr = 'italic'},
	TSFuncMacro = {gfg = tc.gui12, ctfg = 12, attr = 'italic'}, -- macro functions and decls, println! in rust
	TSInclude = {gfg = tc.gui12, ctfg = 12, attr = 'italic'}, -- require, #include
	TSKeyword = {gfg = tc.magenta, ctfg = 5}, -- normal keywrds
	TSKeywordFunction = {gfg = tc.gui12, ctfg = 12}, -- keyword to define function (function in lua)
	TSKeywordOperator = {gfg = tc.yellow, ctfg = 3, attr = 'italic'}, -- word operators (or/and)

	TSLabel = {gfg = tc.gui9, ctfg = 9}, -- ::label:: in lua
	TSMethod = {gfg = tc.blue, ctfg = 4}, -- function calls
--	TSNamespace = {}, -- TODO
	TSNumber = {gfg = tc.red, ctfg = 1},
	TSOperator = {gfg = tc.yellow, ctfg = 3},
	TSParameter = {gfg = tc.yellow, ctfg = 3, attr = 'italic'}, -- function params
-- TSParameterReference = {}, -- TODO
	TSProperty = {gfg = tc.blue, ctfg = 4}, -- access properties: thing.Property
	TSPunctDelimiter = {gfg = tc.fg, ctfg = 7}, -- dot/colon accessors to properties?
	TSPunctBracket = {gfg = tc.fg, ctfg = 7},
	TSPunctSpecial = {gfg = tc.fg, ctfg = 7},
	TSRepeat = {gfg = tc.gui9, ctfg = 9, attr = 'italic'}, -- keywords for loops, while, for, do in lua
	TSString = {gfg = tc.green, ctfg = 2},
	TSStringRegex = {gfg = tc.gui12, ctfg = 12, attr = 'italic'},
	TSStringEscape = {gfg = tc.red, ctfg = 1},
	TSTag = {gfg = tc.yellow, ctfg = 3}, -- html tag names
	TSTagDelimiter = {gfg = tc.gui12, ctfg = 12}, -- < /> in html
	TSURI = {gfg = tc.cyan, ctfg = 6, attr = 'underline'}, -- email/url (should be)
	TSWarning = {gfg = tc.yellow, ctfg = 3},
	TSDanger = {gfg = tc.red, ctfg = 1, attr = 'bold'},
	TSType = {gfg = tc.green, ctfg = 2}, -- custom types
	TSTypeBuiltin = {gfg = tc.green, ctfg = 2, attr = 'italic'}, -- default types
	TSVariableBuiltin = {gfg = tc.gui12, ctfg = 12}, -- builtin vars

	-- Editor Elements
	Normal = {gbg = tc.bg, ctbg = 0},
	ErrorMsg = {gfg = tc.red, ctfg = 1, attr = 'underlineitalic'},
	CursorColumn = {gbg = tc.gui8, ctbg = 8},
	CursorLine = {gbg = tc.bgli, ctbg = 10},
	CursorLineNr = {gfg = tc.fgli, ctfg = 15},
	LineNr = {gfg = tc.gui8, ctfg = 11},
	MoreMsg = {gfg = tc.cyan, ctfg = 6},
	ModeMsg = {gfg = tc.magenta, ctfg = 5, attr = 'bold'},
	Question = {gfg = tc.green, ctfg = 2},
	WarningMsg = {gfg = tc.yellow, ctfg = 3, attr = 'underlineitalic'},
	Title = {gfg = tc.magenta, ctfg = 5},
	Conceal = {gfg = tc.bg, gbg = tc.bg, ctbg = 7, ctfg = 7},
	Search = {gbg = tc.bgvli, ctbg = 11},
	IncSearch = {gbg = tc.bgvli, ctbg = 8},
	Pmenu = {gfg = tc.fgdim, gbg = tc.bgli, ctfg = 15, ctbg = 8},
	PmenuSel = {gfg = tc.bgli, gbg = tc.fgdim, ctfg = 8, ctbg = 15},
	PmenuSbar = {gbg = tc.bgvli, ctbg = 9},
	PmenuThumb = {gbg = tc.bgli, ctbg = 8},
	WildMenu = {gbg = tc.bgvli, ctbg = 11},
	Tabline = {gfg = tc.bg, gbg = tc.fg, ctfg = 0, ctbg = 7, attr = 'underline'},
	TablineSel = {attr = 'bold'},
	TablineFill = {attr = 'reverse'},
	Directory = {gfg = tc.blue, ctfg = 4},
	SpecialKey = {gfg = tc.blue, ctfg = 4},
	TermCursor = {attr = 'reverse'},
	EndOfBuffer = {gfg = tc.bg, gbg = tc.bg, ctfg = 0, ctbg = 0},
	Visual = {gbg = tc.bgvli},
	ColorColumn = {gfg = tc.fg, gbg = tc.gui8, ctfg = 7, ctbg = 8},
	Folded = {gfg = tc.fg, gbg = tc.gui8, ctfg = 7, ctbg = 8},
	FoldColumn = {gfg = tc.bgvli, gbg = tc.bg, ctfg = 7, ctbg = 0},
	StatusLine = {gfg = tc.bg, gbg = tc.bg, ctfg = 0, ctbg = 0, attr = 'bold'},
	StatusLineNC = {gfg = tc.bg, gbg = tc.bg, ctfg = 0, ctbg = 0, force = true},
	SignColumn = {},
	VertSplit = {gfg = tc.bgvli, gbg = tc.bg, ctfg = 0, ctbg = 0},

	-- Buffer Line
	BufferCurrent = {gbg = tc.bg, gfg = tc.fgli, attr = 'italic'},
	BufferCurrentMod = {attr = 'bolditalic'}, -- current modified
	BufferCurrentSign = {gbg = tc.bg, gfg = tc.bg}, -- seems to be some line near the buffer tab
	BufferInactive = {gbg = tc.bgli, gfg = tc.gui8},
	BufferInactiveMod = {gbg = tc.bgli, gfg = tc.yellow}, -- inactive modified (text)
	BufferInactiveSign = {gbg = tc.bgli, gfg = tc.bgli},
	BufferTabpageFill = {gbg = tc.bgli, gfg = tc.bgli}, -- rest of the bufferline
	BufferVisibleSign = {gfg = tc.bgvli, gbg = tc.bg},

	-- Dev Icons
	DevIconLua = {gfg = tc.blue},
	DevIconGo = {gfg = tc.cyan},

	-- NvimTree
	NvimTreeEndOfBuffer = {gfg = tc.bg, gbg = tc.bg, ctfg = 0, ctbg = 0},
	NvimTreeVertSplit = {gfg = tc.bg, gbg = tc.bg, ctfg = 0, ctbg = 0},
	NvimTreeNormal = {gfg = tc.fgli, gbg = tc.bg, ctfg = 7, ctbg = 0},
	NvimTreeRootFolder = {},
	NvimTreeGitDirty = {gfg = tc.blue, ctfg = 4},
	NvimTreeGitNew = {gfg = tc.green, ctfg = 2, attr = 'italic'},
	NvimTreeGitRenamed = {gfg = tc.cyan, ctfg = 6, attr = 'italic'},
	NvimTreeGitStaged = {gfg = tc.green, ctfg = 2},
	NvimTreeStatusLine = {gbg = tc.bgli, gfg = tc.bgli, force = true},
	NvimTreeExecFile = {gfg = tc.green, ctfg = 2, attr = 'underline'},
	NvimTreeGitDeleted = {gfg = tc.red, ctfg = 1, attr = 'bold'},

	-- GitSigns.nvim
	GitSignsAdd = {gfg = tc.green, ctfg = 2},
	GitSignsDelete = {gfg = tc.red, ctfg = 1},
	GitSignsChange = {gfg = tc.blue, ctfg = 4},

	-- Completion Menu (cmp)
	CmpItemAbbrDeprecated = {gfg = tc.red, ctfg = 1, attr = 'strikethrough'}, -- deprecated
	CmpItemAbbrMatch = {gfg = tc.blue, ctfg = 4}, -- matched text in menu
	CmpItemAbbrMatchFuzzy = {gfg = tc.blue, ctfg = 4}, -- ^ fuzzy match
	CmpItemKindVariable = {gfg = tc.cyan, ctfg = 6},
	CmpItemKindInterface = {gfg = tc.cyan, ctfg = 6},
	CmpItemKindText = {gfg = tc.cyan, ctfg = 6},
	CmpItemKindFunction = {gfg = tc.yellow, ctfg = 3},
	CmpItemKindMethod = {gfg = tc.green, ctfg = 2},
	CmpItemKindKeyword = {gfg = tc.yellow, ctfg = 3},
	CmpItemKindProperty = {gfg = tc.blue, ctfg = 4},
	CmpItemKindUnit = {gfg = tc.fgli, ctfg = 7},
}

for group, styles in pairs(highlights) do
	-- if theme has styles for a specific group, use them instead of the defaults
	if tc[group] then
		styles.gbg = tc[group].bg
		styles.gfg = tc[group].fg
		styles.attr = tc[group].attr
	end
    highlight(group, styles.gfg, styles.gbg, styles.ctfg, styles.ctbg, styles.attr, nil, styles.force)
end
