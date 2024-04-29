local beautiful = require 'beautiful'
local gtable = require 'gears.table'
local helpers = require 'helpers'

local textbox = require 'wibox.widget.textbox'

local coloredText = {mt = {}}

function coloredText:set_text(text)
	if not text then return end

	self._private.settext(self, helpers.colorize_text(text, self._private.color))
end

function coloredText:set_color(color)
	self._private.color = color
	self:set_text(self:get_text())
end

local function new(args)
	local ltb = textbox()
	ltb._private.settext = ltb.set_markup
	ltb._private.color = beautiful.fg_normal

	gtable.crush(ltb, coloredText)

	return ltb
end

function coloredText.mt:__call(_, ...)
	return new(...)
end

return setmetatable(coloredText, coloredText.mt)
