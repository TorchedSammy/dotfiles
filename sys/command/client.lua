local command = require 'sys.command'

command.add {
	name = 'client:focus',
	action = function(c)
		c:activate {}
	end
}
