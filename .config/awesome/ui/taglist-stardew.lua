local awful = require 'awful'
local beautiful = require 'beautiful'
local xresources = require 'beautiful.xresources'
local dpi = xresources.apply_dpi
local gears = require 'gears'
local wibox = require 'wibox'
local helpers = require 'helpers'

local ntags = 9

local function taglist(s)
	-- Create textboxes and set their buttons
	local tagwidgets = {}
	local tag_text = {}
	local tagbox = {}

	for i = 1, ntags do
		table.insert(tag_text, wibox.widget {
			valign = 'center',
			align = 'center',
			font = beautiful.taglist_text_font,
			widget = wibox.widget.textbox,
		})
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
		table.insert(tagbox, wibox.widget {
				tag_text[i],
				bg = beautiful.wibar_bg,
				shape = function(cr, w, h)
					-- TODO: make square
					gears.shape.rounded_rect(cr, w, h, 4)
				end,
				shape_border_color = beautiful.wibar_bg,
				shape_border_width = dpi(3),
				widget = wibox.container.background
		})
		table.insert(tagwidgets, tagbox[i])

		tagwidgets[i].forced_width = dpi(32)
	end

	local text_taglist = wibox.widget{
		tagwidgets[1],
		tagwidgets[2],
		tagwidgets[3],
		tagwidgets[4],
		tagwidgets[5],
		tagwidgets[6],
		tagwidgets[7],
		tagwidgets[8],
		tagwidgets[9],
		layout = wibox.layout.fixed.horizontal,
    }

	text_taglist:buttons(gears.table.join(
		-- Middle click - Show clients in current tag
		awful.button({ }, 2, function()
			awful.spawn.with_shell 'rofi -show windowcd'
		end)
	))

	-- Shorter names (eg. tf = text_focused) to save space
	local tf = {'1', '2', '3', '4', '5', '6', '7', '8', '9'}
	local te = tf

	local function update_widget()
		for i = 1, ntags do
			tagbox[i].shape_border_width = 0
			tagbox[i].bg = '#00000000'
			--tag_text[i].markup = helpers.colorize_text(te[i], beautiful.taglist_text_color)
			local tag_clients
			if s.tags[i] then
				tag_clients = s.tags[i]:clients()
			end
			if s.tags[i] and s.tags[i].selected then
				--tag_text[i].markup = helpers.colorize_text(tf[i], cf[i])
				tagbox[i].shape_border_color = beautiful.border_focus
				tagbox[i].shape_border_width = dpi(3)
				tagbox[i].bg = beautiful.bg_sec
				tag_text[i].markup = helpers.colorize_text(te[i], beautiful.taglist_text_focused or beautiful.taglist_text_color)
				--tag_text[i].markup = helpers.colorize_text(tf[i], cf[i])
			elseif s.tags[i] and s.tags[i].urgent then
				--tag_text[i].markup = helpers.colorize_text(tu[i], cu[i])
			elseif tag_clients and #tag_clients > 0 then
				--tag_text[i].markup = helpers.colorize_text(to[i], co[i])
			else
			end
		end
	end

	update_widget()

	client.connect_signal('unmanage', function()
		update_widget()
	end)
	client.connect_signal('untagged', function()
		update_widget()
	end)
	client.connect_signal('tagged', function()
		update_widget()
	end)
	client.connect_signal('screen', function()
		update_widget()
    end)
	awful.tag.attached_connect_signal(s, 'property::selected', function()
		update_widget()
	end)
	awful.tag.attached_connect_signal(s, 'property::hide', function()
		update_widget()
	end)
	awful.tag.attached_connect_signal(s, 'property::activated', function()
		update_widget()
	end)
	awful.tag.attached_connect_signal(s, 'property::screen', function()
		update_widget()
	end)
	awful.tag.attached_connect_signal(s, 'property::index', function()
		update_widget()
	end)
	awful.tag.attached_connect_signal(s, 'property::urgent', function()
		update_widget()
	end)

	return text_taglist
end

return taglist

