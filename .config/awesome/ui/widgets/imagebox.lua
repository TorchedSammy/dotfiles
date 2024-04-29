local gtable = require 'gears.table'
local imagebox = require 'wibox.widget.imagebox'

local ibox = {mt = {}}

function ibox:fit(...)
	print(self._private.default)
	if not self.image then return 0, 0 end
	return self._private.oldFit(...)
end

local function new(...)
	local ib = imagebox(...)
	ib._private.oldFit = ib.fit

	gtable.crush(ib, ibox, true)

	return ib
end

function ibox.mt:__call(...)
	return new(...)
end

return setmetatable(ibox, ibox.mt)
