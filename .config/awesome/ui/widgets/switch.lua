local beautiful = require 'beautiful'
local gtable = require 'gears.table'
local helpers = require 'helpers'
local makeup = require 'ui.makeup'
local gears = require 'gears'
local rubato = require 'libs.rubato'

local base = require 'wibox.widget.base'
local constraint = require 'wibox.container.constraint'
local slider = require 'wibox.widget.slider'

local switch = {mt = {}}

function switch:set_state(on)
	local w = self.children[1]

	self._private.on = on
	self._private.animator.target = on and 100 or 0
	w:emit_signal 'widget::redraw_needed'
end

function switch:get_state()
	return self._private.on
end

function switch:set_handler(cb)
	self._private.handler = cb
end

local function new(args)
	local sldr = base.make_widget(nil, nil, {
		enable_properties = true,
	})

	local size = {
		w = beautiful.dpi(36),
		h = beautiful.dpi(36),
	}

	local color = args.color or beautiful.accent

	gtable.crush(sldr._private, args or {})
	gtable.crush(sldr, slider, true)

	sldr.bar_margins = {
		top = size.h / 3,
		bottom = size.h / 3,
		left = beautiful.dpi(4),
		right = beautiful.dpi(4),
	}
	sldr.bar_color = beautiful.xcolor12
	sldr.bar_active_color = color

	sldr.handle_border_color = color
	sldr.handle_color = beautiful.xcolor7
	sldr.handle_border_width = 0

	sldr.bar_shape = gears.shape.rounded_bar
	sldr.handle_shape = gears.shape.circle
	sldr.value = args.on and 100 or 0

	local ret = constraint(sldr, nil, size.w, size.h)
	gtable.crush(ret, switch, true)

	ret._private.animator = rubato.timed {
		duration = 1,
		rate = 60,
		outro = 0.7,
		easing = {
			F = (20*math.sqrt(3)*math.pi-30*math.log(2)-6147) /
				(10*(2*math.sqrt(3)*math.pi-6147*math.log(2))),
			easing = function(t) return
		(4096*math.pi*(2^(10*t-10))*math.cos(20/3*math.pi*t-43/6*math.pi)
		+6144*(2^(10*t-10))*math.log(2)*math.sin(20/3*math.pi*t-43/6*math.pi)
		+2*math.sqrt(3)*math.pi-3*math.log(2)) /
		(2*math.pi*math.sqrt(3)-6147*math.log(2))
			end
		},
		subscribed = function(p)
			sldr.value = p
		end,
		pos = sldr.value,
	}

	helpers.onLeftClick(ret, function()
		ret:set_state(not ret._private.on)
		if ret._private.handler then
			ret._private.handler(ret, ret._private.on)
		end
	end)

	return ret
end

function switch.mt:__call(...)
	return new(...)
end

return setmetatable(switch, switch.mt)
