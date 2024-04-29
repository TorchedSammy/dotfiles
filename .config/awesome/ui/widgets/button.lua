local awful = require 'awful'
local beautiful = require 'beautiful'
local helpers = require 'helpers'
local gtable = require 'gears.table'
local gears = require 'gears'
local makeup = require 'ui.makeup'
local shape = require 'gears.shape'

local fixed = require 'wibox.layout.fixed'
local margin = require 'wibox.container.margin'
local place = require 'wibox.container.place'

local background = require 'wibox.container.background'
local constraint = require 'wibox.container.constraint'
local icon = require 'ui.widgets.icon'
local imagebox = require 'wibox.widget.imagebox'
local textbox = require 'wibox.widget.textbox'
local widget = require 'wibox.widget'

--[[
local button = {mt = {}}
local defaults = {
	size = beautiful.dpi(18),
	size_strategy = 'exact'
}

function button:set_icon(name)
	self._private.icon.icon = name
end

for prop in pairs {'text', 'color', 'textColor'} do
	icon['set_' .. prop] = function(self, value)
		self._private.icon[prop] = value
		self._private[prop] = value

		if prop == '' then
			
		end
	end
end

for prop in pairs {'onClick', 'iconColor'} do
	icon['set_' .. prop] = function(self, value)
		self._private[prop] = value
	end
end

local function new(args)
	assert(type(args) == 'table', 'expected button args to be a table')
	args.size = args.size or defaults.size
	local ico = icon(args)
	local text = widget {
		widget = textbox,
		markup = helpers.colorize_text(args.text or '', helpers.beautyVar(args.textColor or args.color or 'fg_normal')),
		font = args.font or beautiful.font:gsub('%d+$', args.fontSize or 14),
		valign = 'center'
	}

	local ret = widget {
		layout = constraint,
		--height = args.size,
		strategy = 'exact',
		{
			id = 'bg',
			widget = makeup.putOn(background, {bg = args.bg}, {wibox = args.parentWibox}),
			shape = args.shape or (args.text and helpers.rrect(6) or gears.shape.circle),
			{
				widget = margin,
				margins = args.margin or args.margins or beautiful.dpi(2),
				{
					layout = place,
					halign = args.align or 'center',
					{
						layout = fixed.horizontal,
						--spacing = beautiful.dpi(4),
						ico,
						text,
					}
				}
			}
		}
	}
	ret.buttons = {
		awful.button({}, 1, function()
			if ret._private.onClick then ret._private.onClick(ret) end
		end),
	}
	helpers.displayClickable(ret, args)

	ret._private.icon = ico
	ret._private.textbox = text
	ret._private.onClick = args.onClick

	gtable.crush(ret, button, true)

	return ret
end

function button.mt:__call(...)
	return new(...)
end

return setmetatable(button, button.mt)
]]--

return function(icon, opts)
	local opts = opts or {}
	if type(icon) == 'table' then
		opts = icon
	else
		opts.icon = icon
	end

	opts.color = opts.color or 'fg_normal'

	local focused = false
	local ico = widget {
		layout = constraint,
		height = opts.height,
		strategy = 'exact',
		{
			id = 'bg',
			widget = makeup.putOn(background, {bg = opts.bgcolor or opts.bg}, {wibox = opts.parentWibox}),
			shape = opts.shape or (opts.text and helpers.rrect(6) or gears.shape.circle),
			{
				widget = margin,
				margins = opts.margin or opts.margins or beautiful.dpi(2),
				{
					layout = place,
					halign = opts.align or 'center',
					{
						layout = fixed.horizontal,
						spacing = beautiful.dpi(4),
						(opts.icon ~= '' and opts.icon ~= nil) and {
							layout = place,
							valign = 'center',
							halign = 'center',
							align = 'center',
							{
								widget = constraint,
								width = opts.size and opts.size + 2 or beautiful.dpi(18),
								{
									widget = makeup.putOn(imagebox, function()
										return {
											stylesheet = string.format([[
												* {
													fill: %s;
												}
											]], helpers.beautyVar(opts.makeup or opts.color))
										}
									end),
									image = beautiful.config_path .. '/images/icons/' .. opts.icon .. '.svg',
									id = 'icon'
								},
							},
						} or nil,
						{
							widget = textbox,
							markup = helpers.colorize_text(opts.text or '', helpers.beautyVar(opts.textColor or opts.color)),
							font = opts.font or beautiful.font:gsub('%d+$', opts.fontSize or 14),
							id = 'textbox',
							valign = 'center'
						}
					}
				}
			}
		}
	}
	helpers.displayClickable(ico, opts)

	local function setupIcon()
		--ico:get_children_by_id'icon'[1].image = gears.color.recolor_image(ico:get_children_by_id'icon'[1].image, focused and beautiful.fg_normal .. 55 or beautiful.fg_normal)
		ico:emit_signal 'widget::redraw_needed'
	end

	ico:connect_signal('mouse::enter', function()
		focused = true
		setupIcon()
	end)
	ico:connect_signal('mouse::leave', function()
		focused = false
		setupIcon()
	end)

	ico.visible = true
	local realWid
	realWid = setmetatable({}, {
		__index = function(_, k)
			return ico[k]
		end,
		__newindex = function(_, k, v)
			if k == 'icon' then
				ico:get_children_by_id'icon'[1].image = gears.color.recolor_image(beautiful.config_path .. '/images/icons/' .. v .. '.svg', beautiful.fg_normal)
				ico:emit_signal 'widget::redraw_needed'
			elseif k == 'color' then
				local icon = ico:get_children_by_id'icon'[1]
				opts.color = v
				if icon then
					icon.stylesheet = string.format([[
						* {
							fill: %s;
						}
					]], helpers.beautyVar(opts.iconColor or opts.color))
					ico:emit_signal 'widget::redraw_needed'
				end
			elseif k == 'text' then
				ico:get_children_by_id'textbox'[1].markup = helpers.colorize_text(v, helpers.beautyVar(opts.textColor or opts.color))
			elseif k == 'onClick' and type(v) == 'function' then
				realWid.buttons = {
					awful.button({}, 1, function()
						v(realWid)
					end),
				}
			elseif k == 'makeup' then
				opts.makeup = v
			end
			ico[k] = v
		end
	})
	realWid.buttons = {
		awful.button({}, 1, function()
			if opts.onClick then opts.onClick(realWid) end
		end),
	}

	return realWid
end
