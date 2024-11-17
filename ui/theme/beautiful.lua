local beautiful = require 'beautiful'
local settings = require 'sys.settings'
local palettes = require 'ui.theme.palettes'
local util = require 'sys.util'

local themeSettings = settings.getConfig 'theme'
local palette = palettes[themeSettings.name .. ':' .. themeSettings.type]

local fontName = 'IBM Plex Sans'

beautiful.init {
	fontName = fontName,
	font = fontName .. ' Regular 12',

	titlebarHeight = 42,
	radius = 6,

	barBackground = palette.background,
	panelBackground = palette.shade1,
	
	useless_gap = util.dpi(6)
}
