local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local settings = require 'conf.settings'
local wibox = require 'wibox'

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
  local wbx

  local enterCb = function()
    wbx = mouse.current_wibox
    if wbx then wbx.cursor = cursorType end
  end
  local leaveCb = function()
    if wbx then wbx.cursor = oldCursor end
  end

  w:connect_signal('hover::disconnect', function()
    w:disconnect_signal('mouse::enter', enterCb)
    w:disconnect_signal('mouse::leave', leaveCb)
    leaveCb()
  end)

  w:connect_signal('mouse::enter', enterCb)
  w:connect_signal('mouse::leave', leaveCb)
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
  opts.color = opts.bg or opts.color
  opts.shiftFactor = opts.shiftFactor or -15
  if settings.theme:match '-dark$' then opts.shiftFactor = opts.shiftFactor * -1 end

  local bgWid = w:get_children_by_id 'bg'[1]

  function ecb()
   if bgWid then
      bgWid.bg = opts.hoverColor and opts.hoverColor or helpers.shiftColor(opts.color or w.bg, opts.shiftFactor)
    end
  end

  function lcb()
    if bgWid then
      bgWid.bg = opts.color or w.bg
    end
  end

  w:connect_signal('dc::disconnect', function()
    w:disconnect_signal('mouse::enter', ecb)
    w:disconnect_signal('mouse::leave', lcb)
    lcb()
  end)

  w:connect_signal('mouse::enter', ecb)
  w:connect_signal('mouse::leave', lcb)

  helpers.hoverCursor(w, opts.cursorType)
  return w
end

local onClickHiders = {}
local onClickID = 0
awful.mouse.append_global_mousebinding(awful.button({}, 1, function()
 for _, hider in ipairs(onClickHiders) do
    hider.func()
 end
end))

function helpers.hideOnClick(w, cb)
  local hider = cb or function(widget)
    if widget == w then
      return
    end
    w.visible = false
  end

  table.insert(onClickHiders, {func = hider, widget = w})
  client.connect_signal('button::press', hider)

  w:connect_signal('lol', function(w)
    if not w.visible then
      --wibox.disconnect_signal('button::press', hider)
      client.disconnect_signal('button::press', hider)
      --awful.mouse.remove_global_mousebinding(btn)
    else
      awful.mouse.append_global_mousebinding(btn)
      client.connect_signal('button::press', hider)
      --wibox.connect_signal('button::press', hider)
    end
  end)
end

return helpers
