local settings = require 'conf.settings'
local beautiful = require 'beautiful'
local helpers = require 'helpers'
local wibox = require 'wibox'

local transitionSkip = {
	'stylesheet',
	'markup'
}

local function contains(tbl, val)
	for _, v in ipairs(tbl) do
		if v == val then return true end
	end

	return false
end

local oldBackgroundMt = wibox.container.background.mt
setmetatable(wibox.container.background, {
	__call = function(...)
		local w = oldBackgroundMt.__call(...)
		if w.bgKey then
			w.bg = beautiful[w.bgKey]
		end

		awesome.connect_signal('makeup::put_on', function()
			if w.bgKey then
				w.bg = beautiful[w.beautifulKey]
			end
		end)

		return w
	end
})

local M = {}

function M.putOn(widget, handle, opts)
	opts = opts or {}
	return setmetatable({}, { __call = function(_, ...)
		local w = widget(opts.args)

		local function handleColor(k, v)
			if type(v) == 'userdata' or type(v) == 'table' or contains(transitionSkip, k) then return v end

			return v:match '^#' and v or beautiful[v]
		end

		local set
		if type(handle) == 'table' then
			set = handle
		elseif type(handle) == 'function' then
			set = handle(w, true)
		else
			error('invalid type for makeup handler added (expected either function or table)')
		end

		for k, v in pairs(set) do
			w[k] = handleColor(k, v)
		end

		awesome.connect_signal('makeup::put_on', function()
			local changed

			if type(handle) == 'table' then
				changed = handle
			elseif type(handle) == 'function' then
				changed = handle(w, false)
			else
				error('invalid type for makeup handler added (expected either function or table)')
			end

			local visible = false
			if opts.wibox then visible = opts.wibox.visible end

			for k, v in pairs(changed) do
				local colorizer = function()
					helpers.transitionColor {
						old = handleColor(k, w[k]),
						new = handleColor(k, v),
						transformer = function(c) w[k] = c end,
						duration = 4,
						animate = visible
					}
				end

				if type(v) ~= 'table' and k ~= 'stylesheet' and k ~= 'markup' then
					if opts.wibox and not visible then
						local colorizerOnDemand
						colorizerOnDemand = function()
							colorizer()
							opts.wibox:disconnect_signal('property::visible', colorizerOnDemand)
						end
						opts.wibox:connect_signal('property::visible', colorizerOnDemand)
					else
						colorizer()
					end
				else
					w[k] = v
				end
				if visible then
					w:emit_signal 'widget::redraw_needed'
				end
			end
		end)

		return w
	end })
end

function M.setupTheme()
	beautiful.init('~/.config/awesome/themes/' .. settings.theme .. '.lua')
end

function copy(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end

function M.retheme()
	local oldTheme = copy(beautiful)
	M.setupTheme()
	awesome.emit_signal('makeup::put_on', oldTheme)
end

return M
