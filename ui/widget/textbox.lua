local beautiful = require 'beautiful'
local gtable = require 'gears.table'
local util = require 'sys.util'

local textbox = require 'wibox.widget.textbox'

local coloredText = {mt = {}}

function coloredText:set_text(text)
	if not text then return end

	self._private.settext(self, util.colorizeText(text, self._private.color))
end

function coloredText:set_color(color)
	self._private.color = color
	self:set_text(self:get_text())
end

local function new(args)
	local ltb = textbox()
	ltb._private.settext = ltb.set_markup
	ltb._private.color = beautiful.foreground

	gtable.crush(ltb, coloredText)
	awesome.connect_signal('makeup::put_on', function() ltb:set_color(ltb._private.color) end)

	return ltb
end

function coloredText.mt:__call(_, ...)
	return new(...)
end

return setmetatable(coloredText, coloredText.mt)
