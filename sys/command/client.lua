local command = require 'sys.command'

command.add {
	name = 'client:focus',
	action = function(c)
		c:activate { raise = true }
	end
}

command.add {
	name = 'client:move',
	action = function(c)
		c:activate { raise = true, action = 'mouse_move'  }
	end
}

command.add {
	name = 'client:resize',
	action = function(c)
		c:activate { raise = true, action = 'mouse_resize'  }
	end
}

command.add {
	name = 'client:maximize',
	action = function(c)
		c.maximized = not c.maximized
		c:raise()
	end
}

command.add {
	name = 'client:fullscreen',
	action = function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end
}
