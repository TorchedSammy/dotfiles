local core = require 'core'
local keymap = require 'core.keymap'
local config = require 'core.config'
local style = require 'core.style'

config.ignore_files = {'^%.git$'}
local function ignoreExt(...)
	local exts = {...}
	for i in ipairs(exts) do
		table.insert(config.ignore_files, '[%w-.]+.' .. exts[i])
	end
end
ignoreExt('png')

------------------------------ Themes ----------------------------------------

-- light theme:
-- core.reload_module("colors.summer")

--------------------------- Key bindings -------------------------------------

-- key binding:
-- keymap.add { ["ctrl+escape"] = "core:quit" }


------------------------------- Fonts ----------------------------------------
-- customize fonts:
-- style.font = renderer.font.load(DATADIR .. "/fonts/FiraSans-Regular.ttf", 14 * SCALE)
-- style.code_font = renderer.font.load(DATADIR .. "/fonts/.ttf", 10 * SCALE)
--
-- font names used by lite:
-- style.font          : user interface
-- style.big_font      : big text in welcome screen
-- style.icon_font     : icons
-- style.icon_big_font : toolbar icons
-- style.code_font     : code
--
-- the function to load the font accept a 3rd optional argument like:
--
-- {antialiasing="grayscale", hinting="full"}
--
-- possible values are:
-- antialiasing: grayscale, subpixel
-- hinting: none, slight, full

------------------------------ Plugins ----------------------------------------

-- enable or disable plugin loading setting config entries:

-- enable plugins.trimwhitespace, otherwise it is disable by default:
-- config.plugins.trimwhitespace = true
--
-- disable detectindent, otherwise it is enabled by default
config.plugins.detectindent = false
config.tab_type = "hard"
config.indent_size = 4   -- 4 spaces

local common = require "core.common"
local RootView = require "core.rootview"
local rv_draw = RootView.draw
local time = ''
local date = ''
local time_width = 0
local time_height = 0
local date_width = 0

core.add_thread(function()
	while true do
		time = os.date '%I:%M %p'
		date = os.date '%a, %d %b'
		time_width = style.code_font:get_width(time)
		date_width = style.code_font:get_width(date)
		time_height = style.code_font:get_height()
		coroutine.yield(1)
	end
end)

function RootView:draw(...)
	rv_draw(self, ...)
	renderer.draw_text(style.code_font, date, self.size.x - date_width - 25, self.size.y - (time_height * 2) - 60, style.text)
	renderer.draw_text(style.code_font, time, self.size.x - time_width - 25, self.size.y - time_height - 60, style.text)
end
