local awful = require 'awful'
local beautiful = require 'beautiful'
local gears = require 'gears'
local settings = require 'conf.settings'
local naughty = require 'naughty'
local wibox = require 'wibox'
local rubato = require 'libs.rubato'
local lgi = require 'lgi'
local focus = require 'conf.focus'

local Color = require 'lua-color'

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

function helpers.minimize(c)
 gears.timer.delayed_call(function() c.minimized = true end)
end

function helpers.winmaxer(c)
  awful.placement.maximize(c, {
    honor_padding = true,
    honor_workarea = true,
    --margins = beautiful.useless_gap * beautiful.dpi(2)
  })
end

function helpers.hoverCursor(w, cursorType)
  cursorType = cursorType or 'hand2'
  local oldCursor = 'left_ptr'
  local wbx

 w.hcDisabled = false
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

  function w:toggleHoverCursor()
   w.hcDisabled = not w.hcDisabled
   if w.hcDisabled then
    leaveCb()
   else
    enterCb()
   end
  end

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

function helpers.invertColor(color, bw)
  local num = tonumber(color:sub(2), 16)
  local r = math.floor(num / 0x10000)
  local g = (math.floor(num / 0x100) % 0x100)
  local b = (num % 0x100)

  if bw then
    return (r * 0.299 + g * 0.587 + b * 0.114) > 186 and '#000000' or '#ffffff'
  end

  r = 0xff - math.floor(num / 0x10000)
  g = 0xff - (math.floor(num / 0x100) % 0x100)
  b = 0xff - (num % 0x100)

  return string.format('%#x', clamp(r) * 0x10000 + clamp(g) * 0x100 + clamp(b)):gsub('0x', '#')
end

function helpers.onLeftClick(w, cb)
 	w.buttons = {
   awful.button({}, 1, function()
    cb()
   end),
  }
end
function helpers.displayClickable(w, opts)
  opts = type(opts) == 'table' and opts or {}
  opts.shiftFactor = opts.shiftFactor or -15
  if settings.theme:match '-dark$' or beautiful.dark then opts.shiftFactor = opts.shiftFactor * -1 end

  local bgWid = w:get_children_by_id 'bg'[1]
  w.dcDisabled = false

  function ecb()
   if bgWid and not w.dcDisabled and opts.bg then
      bgWid.bg = opts.hoverColor and opts.hoverColor or helpers.shiftColor(opts.bg or w.bg, opts.shiftFactor)
    end
  end

  function lcb()
    if bgWid and opts.bg then
      bgWid.bg = opts.bg
    end
  end

  w:connect_signal('dc::disconnect', function()
    w:disconnect_signal('mouse::enter', ecb)
    w:disconnect_signal('mouse::leave', lcb)
    lcb()
  end)

  function w:toggleClickableDisplay()
   w.dcDisabled = not w.dcDisabled
   if w.dcDisabled then
    bgWid.bg = opts.bg
   else
    bgWid.bg = opts.hoverColor and opts.hoverColor or helpers.shiftColor(opts.bg or w.bg, opts.shiftFactor)
   end
  end

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
 local hider = function(widget)
  if widget == w then
   return
  end

  if cb then cb() else w.visible = false end
 end

  table.insert(onClickHiders, {func = hider, widget = w})
  client.connect_signal('button::press', hider)
  client.connect_signal('request::activate', function()
   if focus.shouldUnfocus() then hider() end
  end)
  --wibox.connect_signal('button::press', hider)

  w:connect_signal('lol', function(w)
    if not w.visible then
      wibox.disconnect_signal('button::press', hider)
      client.disconnect_signal('button::press', hider)
      --awful.mouse.remove_global_mousebinding(btn)
    else
      awful.mouse.append_global_mousebinding(btn)
      client.connect_signal('button::press', hider)
      wibox.connect_signal('button::press', hider)
    end
  end)
end

function helpers.unimplemented(mod, func)
	naughty.notify {
		title = 'Missing Implementation',
		text = string.format('%s: missing implementation of function %s', mod, func)
	}
end

function helpers.implWrap(mod)
 return function(func)
  helpers.unimplemented(mod, func)
 end
end

function helpers.slidePlacement(wbx, opts)
 local wbxOpen = false
 local hideHeight = awful.screen.focused().geometry.height
 local animator = (opts.animator and opts.animator(wbx)) or rubato.timed {
		duration = 0.3,
		rate = 60,
		subscribed = function(y)
			wbx.y = y
			if y == hideHeight then
    wbx.visible = false
			end
		end,
		pos = hideHeight,
		easing = {
     F = 1/3,
     easing = function(t) return t*t end
  },
  clamp_position = true
	}
	local placer = type(opts.placement) == 'string' and awful.placement[opts.placement] or opts.placement
 local function doPlacement()
		placer(wbx, {
			margins = {
				left = beautiful.useless_gap * beautiful.dpi(2),
				right = beautiful.useless_gap * beautiful.dpi(2),
				bottom = settings.noAnimate and beautiful.wibar_height + beautiful.useless_gap * beautiful.dpi(2) or -wbx.height
			},
			parent = awful.screen.focused()
		})
	end
	doPlacement()
	wbx.visible = false

	if settings.noAnimate then
		helpers.hideOnClick(wbx)
	else
		helpers.hideOnClick(wbx, function()
			if wbxOpen and not settings.noAnimate then
				wbx:off()
			end
		end)
	end

 function wbx:on()
  animator.target = awful.screen.focused().geometry.height - (beautiful.wibar_height + beautiful.useless_gap * beautiful.dpi(2)) - wbx.height
  wbx.visible = true
  wbxOpen = true
  wbx.displayed = true

  if opts.toggler then
    local continue = opts.toggler(wbxOpen)
    if continue == false then
      return
    end
  end
 end

 function wbx:off()
		wbxOpen = false
		animator.target = awful.screen.focused().geometry.height
    wbx.displayed = false

    if opts.toggler then
      local continue = opts.toggler(wbxOpen)
      if continue == false then
        return
      end
    end
 end

	function wbx:toggle()
		if not wbxOpen then
			doPlacement()
		end

		if settings.noAnimate then
			wbx.visible = not wbx.visible
		else
			if wbxOpen then
				wbx:off()
			else
        wbx:on()
			end
		end
	end
end

function helpers.transitionColor(opts)
 local old = Color(opts.old)
 local new = Color(opts.new)
 local animator = rubato.timed {
  duration = opts.duration or 2,
		rate = 60,
		override_dt = false,
		subscribed = function(perc)
   opts.transformer(tostring(old:mix(new, perc / 100)))
		end,
		pos = 0,
		easing = opts.easing or rubato.quadratic,
		clamp_position = true
	}
	animator.target = 100
end

function helpers.changedDBusProperty(proxy, property, callback)
 proxy:on_properties_changed(function(_, changed)
  if changed[property] ~= nil then
   callback(changed[property])
  end
 end)
end

function helpers.glibByteToVal(b)
 if not b then return end

	return lgi.GLib.Bytes(b):get_data()
end

function helpers.aaWibox(opts)
 local bg = opts.bg

 opts.bg = '#00000000'
 if opts.rrectRadius then
  opts.bg = bg
  opts.shape = helpers.rrect(opts.rrectRadius / 1.5)
 end

 local wbx = wibox(opts)

 local oldSetup = wbx.setup
 function wbx:setup(wid)
  local setupWidget = wibox.widget {
   widget = wibox.container.background,
   bg = bg,
   shape = helpers.rrect(opts.rrectRadius),
   forced_height = wbx.height,
   forced_width = wbx.width,
   wid
  }
  oldSetup(wbx, {
   layout = wibox.container.place,
   setupWidget
  })

--[[
  local function redraw()
   setupWidget:emit_signal 'widget::redraw_needed'
  end
  awesome.connect_signal('compositor::off', redraw)
  awesome.connect_signal('compositor::on', redraw)
 ]]--
 end
 return wbx
end
return helpers
