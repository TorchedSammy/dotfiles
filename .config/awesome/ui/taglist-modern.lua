local awful = require 'awful'
local beautiful = require 'beautiful'
local xresources = require 'beautiful.xresources'
local gears = require 'gears'
local rubato = require 'libs.rubato'
local wibox = require 'wibox'
local helpers = require 'helpers'

local function setup(s, vertical)
	local tf, tu, to, te, cf, cu, co, ce;
	local function colors()
		-- Set fallback values if needed
		if beautiful.taglist_text_focused then
			tf = beautiful.taglist_text_focused
			tu = beautiful.taglist_text_urgent
			to = beautiful.taglist_text_occupied
			te = beautiful.taglist_text_empty
			cf = beautiful.taglist_text_color_focused
			cu = beautiful.taglist_text_color_urgent
			co = beautiful.taglist_text_color_occupied
			ce = beautiful.taglist_text_color_empty
		else
			-- Fallback values
			tf = {'1', '2', '3', '4', '5', '6', '7', '8', '9'}
			tu = tf
			to = tf
			te = tf

			local ff = beautiful.fg_focus
			local fu = beautiful.fg_urgent
			local fo = beautiful.fg_normal
			local fe = beautiful.fg_minimize

			cf = {ff, ff, ff, ff, ff, ff, ff, ff, ff, ff}
			cu = {fu, fu, fu, fu, fu, fu, fu, fu, fu, fu}
			co = {fo, fo, fo, fo, fo, fo, fo, fo, fo, fo}
			ce = {fe, fe, fe, fe, fe, fe, fe, fe, fe, fe}
		end
	end

	colors()

	local baseSize = beautiful.taglist_size or beautiful.dpi(13)
	local expandedSize = beautiful.taglist_expanded_size or beautiful.dpi(15)
	local taglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		layout = {
			layout = wibox.layout.fixed.horizontal
		},
		style = {
			spacing = 5
		},
		widget_template = {
			{
				{
					widget = wibox.widget.textbox,
					markup = ''
				},
				id = 'tag',
				widget = wibox.container.background,
				forced_width = baseSize,
				forced_height = baseSize,
				shape = gears.shape.rounded_bar,
			},
			widget = wibox.container.place,
			create_callback = function(self, t, _, _)
				local w = self:get_children_by_id 'tag'[1]
				self.animator = rubato.timed {
					intro = 0.02,
					duration = 0.25,
					override_dt = false,
					subscribed = function(width)
						w.forced_width = width
					end
				}

				function self.update()
					local i = t.index

					local clients = t:clients()
					if t.selected then
						self.animator.target = baseSize + expandedSize
						if beautiful.taglist_active_gradient then
							w.bg = {
								type  = 'linear' ,
								from  = {
									0,
									0
								},
								to = {
									baseSize + expandedSize,
									baseSize
								},
								stops = {
									{
										0,
										cf[i]
									},
									{
										1,
										helpers.shiftColor(cf[i], -50)
									}
								}
							}
						else
							w.bg = cf[i]
						end
					elseif t.urgent then
						self.animator.target = baseSize + expandedSize
						w.bg = cu[i]
						w.markup = helpers.colorize_text(tu[i], cu[i])
					elseif clients and #clients > 0 then
						self.animator.target = baseSize
						w.bg = co[i]
					else
						self.animator.target = baseSize
						w.bg = ce[i]
					end
				end

				self.update()
			end,
			update_callback = function(self, _, _, _)
				self.update()
			end,
		},
		--buttons = taglist_buttons
	}

	awesome.connect_signal('makeup::put_on', function()
		colors()
		taglist._do_taglist_update() -- private function! oops!
	end)

	--[[
		tag_text[i]:buttons(gears.table.join(
			-- Left click - Tag back and forth
			awful.button({ }, 1, function()
				local current_tag = s.selected_tag
				local clicked_tag = s.tags[i]
				if clicked_tag == current_tag then
					awful.tag.history.restore()
				else
					clicked_tag:view_only()
				end
			end),
			-- Right click - Move focused client to tag
			awful.button({ }, 3, function()
				local clicked_tag = s.tags[i]
				if client.focus then
					client.focus:move_to_tag(clicked_tag)
				end
			end)
		))
]]--

	local t = wibox.widget {
		widget = wibox.container.margin,
		left = 5, right = 5,
		bottom = 2, top = 2,
		taglist
	}

	if vertical then
		return wibox.widget {
			widget = wibox.container.rotate,
			direction = 'west',
			t
		}
	else
		return t
	end
end

return setup



