local gtable = require 'gears.table'
local helpers = require 'helpers'

local textbox = require 'wibox.widget.textbox'

local tb = {mt = {}}

function tb:set_color(color)
	self.markup = helpers.colorize_text(self.text, helpers.beautyVar(color))
end

local function new(...)
	local ltb = textbox(...)
	gtable.crush(ltb, tb)

	return ltb
end

function tb.mt:__call(...)
	return new(...)
end

return setmetatable(tb, tb.mt)
