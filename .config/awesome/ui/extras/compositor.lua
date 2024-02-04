local compositor = require 'modules.compositor'
local beautiful = require 'beautiful'
local gears = require 'gears'

awesome.connect_signal('compositor::off', function()
	for _, c in ipairs(client.get()) do
		if not c.fullscreen then
			c.shape = beautiful.client_shape
		end
	end
end)

awesome.connect_signal('compositor::on', function()
	for _, c in ipairs(client.get()) do
		c.shape = nil
	end
end)

client.connect_signal('property::fullscreen', function(c)
	if c.fullscreen then
		c.shape = nil
	else
		c.shape = compositor.state() and nil or beautiful.client_shape
	end
end)

client.connect_signal('manage', function(c)
	if beautiful.client_shape and not compositor.running and not c.fullscreen then
		c.shape = beautiful.client_shape
	end
end)
