local wibox = require 'wibox'

local button = {mt = {}}

-- @tparam[opt={}] table args
-- @tparam[opt] string args.label The text to display on the button
-- @tparam[opt] string args.icon The name of the icon to use
-- @tparam[opt] string args.color Color to use for the button background
-- @tparam[opt] string args.textColor Color to use for the button text
function new(args)
	
end

function button.mt:__call(...)
	return new(...)
end

return setmetatable(button, button.mt)
