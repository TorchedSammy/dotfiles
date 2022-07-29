local awful = require 'awful'
local base = require 'ui.components.syntax.base'
local beautiful = require 'beautiful'
local gears = require 'gears'
local helpers = require 'helpers'
local wibox = require 'wibox'
local lgi = require 'lgi'
local glib = lgi.GLib
local gio = lgi.Gio
local naughty = require 'naughty'

local function button(color_focus, txt, font)
	local focused = false
	local ico = wibox.widget {
		markup = helpers.colorize_text(txt, color_focus),
		font = font or 'VictorMono NF 16',
		widget = wibox.widget.textbox,
		icon = txt
	}

	local function setupIcon()
		ico.markup = helpers.colorize_text(ico.icon, focused and color_focus .. 55 or color_focus)
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
	return setmetatable({}, {
		__index = function(_, k)
			return ico[k]
		end,
		__newindex = function(_, k, v)
			ico[k] = v
			if k == 'icon' then
				setupIcon()
			elseif k == 'color' then
				color_focus = v
				setupIcon()
			end
		end
	})
end

local function input(stream, line)
	stream:put_string(line .. '\n')
end

local function spawn(cmd, callbacks)
	    local stdout_callback, stderr_callback, done_callback, exit_callback =
        callbacks.stdout, callbacks.stderr, callbacks.output_done, callbacks.exit
    local have_stdout, have_stderr = stdout_callback ~= nil, stderr_callback ~= nil
    local pid, _, stdin, stdout, stderr = awesome.spawn(cmd,
            false, true, have_stdout, have_stderr, exit_callback)
    if type(pid) == "string" then
        -- Error
        return pid
    end

    local done_before = false
    local function step_done()
        if have_stdout and have_stderr and not done_before then
            done_before = true
            return
        end
        if done_callback then
            done_callback()
        end
    end
    if have_stdout then
        awful.spawn.read_lines(gio.UnixInputStream.new(stdout, true),
                stdout_callback, step_done, true)
    end
    if have_stderr then
        awful.spawn.read_lines(gio.UnixInputStream.new(stderr, true),
                stderr_callback, step_done, true)
    end
    return pid, stdin
end

local function setupUI(c)
	local uiHeight = beautiful.dpi(86)

	local progressPaddings = 4
	local progress = wibox.widget {
		widget = wibox.widget.progressbar,
		forced_height = 18,
		paddings = progressPaddings,
		background_color = beautiful.bg_normal,
		max_value = 100
	}
	local volumeBarWidth = 180
	local volume = wibox.widget {
		widget = wibox.widget.progressbar,
		shape = gears.shape.rounded_bar,
		forced_height = 8,
		background_color = '#00000000',
		color = string.format('linear:0,0:%s,0:0,%s:%s,%s', volumeBarWidth, base.gradientColors[1], volumeBarWidth, base.gradientColors[2]),
		max_value = 100
	}

	local lightColor = beautiful.xcolor11
	local slider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = progress.forced_height,
		bar_color = '#00000000',
		handle_width = progress.forced_height - progressPaddings / 5,
		handle_color = beautiful.bg_normal,
		handle_shape = gears.shape.circle,
		handle_border_color = lightColor,
		handle_border_width = 1,
		maximum = 100
	}
	local volumeSlider = wibox.widget {
		widget = wibox.widget.slider,
		forced_height = progress.forced_height,
		bar_color = '#00000000',
		bar_shape = beautiful.rounded_bar,
		handle_width = progress.forced_height - progressPaddings / 5,
		handle_color = beautiful.bg_normal,
		handle_shape = gears.shape.circle,
		handle_border_color = lightColor,
		handle_border_width = 1,
		maximum = 100
	}

	local playPauseIcons = {'契', ''}
	local shuffleIcons = {'劣', '列'}
	local buttonColor = beautiful.xcolor7
	local prev = button(buttonColor, '玲')
	local playPause = button(buttonColor, playPauseIcons[2])
	local next = button(buttonColor, '怜')
	local shuffle = button(buttonColor, shuffleIcons[2], 'VictorMono NF 20')

	local stdin
	local stream
	local ignore = false
    pid, stdin = spawn('socat - /tmp/mpv-socks/' .. c.pid, {
        stdout = function(line)
			if not c then return end
			local obj = load('return ' .. ((line:gsub('%[', '{')):gsub('%]', '}')):gsub('("[^"]-"):', '[%1]='))()
			if obj then
				if obj.event == 'client-message' and obj.args[1] == 'volumestat' then
					local volNum = tonumber(obj.args[2])
					volume.value = volNum
					volumeSlider._private.value = volNum
					volumeSlider:emit_signal 'widget::redraw_needed'
				end

				if obj.event == 'pause' then
					playPause.icon = playPauseIcons[1]
				elseif obj.event == 'unpause' then
					playPause.icon = playPauseIcons[2]
				end

				if obj.event == 'property-change' then
					if obj.name == 'percent-pos' and not ignore then
						local percent = obj.data
						if percent % 0.5 > 0.99 then return end
						progress.color = string.format('linear:0,0:%s,0:0,%s:%s,%s', c.width, base.gradientColors[1], c.width, base.gradientColors[2])
						progress.value = percent
						-- !! private api spooky !!
						-- a normal value change causes our signal below to get emitted, and
						-- i'm sure you can imagine what happens then
						slider._private.value = percent - 0.17
						slider:emit_signal 'widget::redraw_needed'
					elseif obj.name == 'shuffle' then
						local shuffled = obj.data
						if shuffled then
							shuffle.color = beautiful.xcolor2
						else
							shuffle.color = buttonColor
						end
					end
				end

				if obj.event == 'seek' then
					ignore = true
				else
					ignore = false
				end
			end
        end
    })
    local outputStream = gio.UnixOutputStream.new(stdin, true)
    stream = gio.DataOutputStream.new(outputStream)

	input(stream, 'script-message osc-visibility never')
    input(stream, '{"command": ["observe_property", 1, "percent-pos"]}')
    input(stream, 'script-message volume')
    input(stream, '{"command": ["observe_property", 1, "shuffle"]}')

	slider:connect_signal('property::value', function()
		input(stream, 'set percent-pos ' .. tostring(slider.value))
		progress.value = slider.value
	end)
	volumeSlider:connect_signal('property::value', function()
		input(stream, 'set volume ' .. tostring(volumeSlider.value))
		volume.value = volumeSlider.value
	end)
	prev:connect_signal('button::press', function()
		input(stream, 'playlist-prev')
	end)
	playPause:connect_signal('button::press', function()
		input(stream, 'cycle pause')
	end)
	next:connect_signal('button::press', function()
		input(stream, 'playlist-next')
	end)
	shuffle:connect_signal('button::press', function()
		input(stream, 'script-message shuffle')
	end)

	local progressBar = wibox.widget {
		layout = wibox.layout.stack,
		progress,
		{
			layout = wibox.container.place,
			halign = 'center',
			valign = 'center',
			{
				widget = wibox.container.margin,
				top = progressPaddings / 2, bottom = progressPaddings / 2,
				slider
			}
		}
	}
	local volumeBar = wibox.widget {
		layout = wibox.layout.stack,
		{
			layout = wibox.container.place,
			halign = 'center',
			valign = 'center',
			{
				widget = wibox.container.margin,
				top = 4, bottom = 4, left = 2, right = 2,
				{
					layout = wibox.layout.stack,
					{
						widget = wibox.container.background,
						shape = gears.shape.rounded_bar,
						bg = beautiful.bg_sec,
						{
							widget = wibox.widget.textbox,
							text = ''
						}
					},
					volume
				}
			}
		},
		volumeSlider
	}

	awful.titlebar(c, {size = uiHeight, bg = '#00000000', position = 'bottom'}): setup {
		layout = wibox.layout.fixed.vertical,
		progressBar,
		{
			widget = wibox.widget.separator,
			color = lightColor,
			forced_height = beautiful.dpi(1),
			thickness = 1,
		},
		{
			layout = wibox.layout.align.horizontal,
			base.sideDecor {
				h = uiHeight - progress.forced_height,
			},
			{
				shape = gears.shape.rectangle,
				bg = beautiful.bg_normal,
				widget = wibox.container.background,
				forced_height = uiHeight,
				{
					widget = wibox.container.margin,
					top = 12, bottom = 12, right = base.widths.empty * 2,
					{
						layout = wibox.layout.align.horizontal,
						{
							widget = wibox.container.background,
							shape = base.shape,
							forced_width = beautiful.dpi(140),
							shape_border_width = 1,
							shape_border_color = lightColor,
							{
								layout = wibox.container.place,
								halign = 'center',
								{
									layout = wibox.layout.fixed.horizontal,
									spacing = 16,
									prev,
									{
										widget = wibox.widget.separator,
										color = lightColor,
										forced_width = beautiful.dpi(1),
										thickness = 1,
										orientation = 'vertical',
									},
									playPause,
									{
										widget = wibox.widget.separator,
										color = lightColor,
										forced_width = beautiful.dpi(1),
										thickness = 1,
										orientation = 'vertical',
									},
									next
								}
							}
						},
						{
							layout = wibox.layout.fixed.horizontal
						},
						{
							layout = wibox.layout.fixed.horizontal,
							spacing = 8,
							{
								widget = wibox.container.constraint,
								width = volumeBarWidth,
								volumeBar,
							},
							shuffle
						},
					},
				}
			}
		}
	}
end

client.connect_signal('manage', function(c)
	if c.class == 'mpv' then
		setupUI(c)
	end
end)

return setupUI
