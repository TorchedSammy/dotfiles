local awful = require 'awful'
local beautiful = require 'beautiful'
local xresources = require 'beautiful.xresources'
local dpi = xresources.apply_dpi
local gears = require 'gears'
local wibox = require 'wibox'
local helpers = require 'helpers'

local function setup(s)
	local tf, tu, to, te, cf, cu, co, ce;
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

	local function update(self, t)
		local w = self:get_children_by_id 'tag'[1]
		local i = t.index

		local clients = t:clients()
		if t.selected then
			w.markup = helpers.colorize_text(tf[i], cf[i])
		elseif t.urgent then
			w.markup = helpers.colorize_text(tu[i], cu[i])
		elseif clients and #clients > 0 then
			w.markup = helpers.colorize_text(to[i], co[i])
		else
			w.markup = helpers.colorize_text(te[i], ce[i])
		end
	end

	local taglist = awful.widget.taglist {
		screen = s,
		filter = awful.widget.taglist.filter.all,
		layout = {
			layout = wibox.layout.fixed.horizontal
		},
		widget_template = {
			id = 'tag',
			font = beautiful.taglist_text_font,
			forced_width = dpi(25),
			align = 'center',
			valign = 'center',
			widget = wibox.widget.textbox,
			-- Add support for hover colors and an index label
			create_callback = function(self, t, _, _)
				update(self, t)
			end,
			update_callback = function(self, t, _, _)
				update(self, t)
			end,
		},
		--buttons = taglist_buttons
	}
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

	return taglist
end

return setup

