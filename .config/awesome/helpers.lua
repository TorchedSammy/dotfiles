local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local settings = require 'conf.settings'

local helpers = {}

function helpers.rrect(radius)
	return function(c, width, height)
		gears.shape.rounded_rect(c, width, height, radius)
	end
end

function helpers.colorize_text(text, color)
	return '<span foreground="' .. color ..'">' .. text .. '</span>'
end

function helpers.set_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == 'function' then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

function helpers.maximize(c)
    c.maximized = not c.maximized
    if c.maximized then
        helpers.winmaxer(c)
    end
    c:raise()
end

function helpers.winmaxer(c)
  awful.placement.maximize(c, {
    honor_padding = true,
    honor_workarea = true,
    margins = beautiful.useless_gap * beautiful.dpi(2)
  })
end

function helpers.hoverCursor(w, cursorType)
  cursorType = cursorType or 'hand2'
  local oldCursor = 'left_ptr'

  w:connect_signal('mouse::enter', function()
    local wbx = mouse.current_wibox
    if wbx then wbx.cursor = cursorType end
  end)

  w:connect_signal('mouse::leave', function()
    local wbx = mouse.current_wibox
    if wbx then wbx.cursor = oldCursor end
  end)
end

local function clamp(component)
  return math.min(math.max(component, 0), 255)
end

function helpers.shiftColor(color, percent)
  local num = tonumber(color:sub(2), 16)
  local r = math.floor(num / 0x10000) + percent
  local g = (math.floor(num / 0x100) % 0x100) + percent
  local b = (num % 0x100) + percent

  return string.format('%#x', clamp(r) * 0x10000 + clamp(g) * 0x100 + clamp(b)):gsub('0x', '#')
end

function helpers.invertColor(color)
  local num = tonumber(color:sub(2), 16)
  local r = 0xff - math.floor(num / 0x10000)
  local g = 0xff - (math.floor(num / 0x100) % 0x100)
  local b = 0xff - (num % 0x100)

  return string.format('%#x', clamp(r) * 0x10000 + clamp(g) * 0x100 + clamp(b)):gsub('0x', '#')
end

function helpers.displayClickable(w, opts)
  opts = type(opts) == 'table' and opts or {}
  opts.shiftFactor = opts.shiftFactor or -15
  if settings.theme:match '-dark$' then opts.shiftFactor = opts.shiftFactor * -1 end

  local bgWid = w:get_children_by_id 'bg'[1]
  helpers.hoverCursor(w, opts.cursorType)

  w:connect_signal('mouse::enter', function()
    if bgWid then
      bgWid.bg = opts.hoverColor and opts.hoverColor or helpers.shiftColor(opts.color, opts.shiftFactor)
    end
  end)

  w:connect_signal('mouse::leave', function()
    if bgWid then
      bgWid.bg = opts.color
    end
  end)

  return w
end

return helpers

