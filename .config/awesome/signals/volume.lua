local awful = require 'awful'

local volume_old = -1
local muted_old = false
local function emit_volume_info(init)
    -- Get volume info of the currently active sink
    -- The currently active sink has a star `*` in front of its index
    -- In the output of `pacmd list-sinks`, lines +7 and +11 after '* index:'
    -- contain the volume level and muted state respectively
    -- This is why we are using `awk` to print them.
    awful.spawn.easy_async_with_shell(
        'pacmd list-sinks | awk \'/\\* index: /{nr[NR+7];nr[NR+11]}; NR in nr\'',
        function(stdout)
            local volume = stdout:match('(%d+)%% /')
            local muted = stdout:match('muted:%s+(%w+)') == 'yes'
            local volume_int = tonumber(volume)
            -- Only send signal if there was a change
            -- We need this since we use `pactl subscribe` to detect
            -- volume events. These are not only triggered when the
            -- user adjusts the volume through a keybind, but also
            -- through `pavucontrol` or even without user intervention,
            -- when a media file starts playing.
            if volume_int ~= volume_old or muted ~= muted_old then
                awesome.emit_signal('syntax::volume', volume_int, muted, init)
                volume_old = volume_int
                muted_old = muted
            end
        end)
end

--emit_volume_info()

-- Sleeps until pactl detects an event (volume up/down/toggle mute)
local volume_script = [[
    bash -c "
    LANG=C pactl subscribe 2> /dev/null | grep --line-buffered \"Event 'change' on sink\"
    "]]

-- Kill old pactl subscribe processes
awful.spawn.easy_async({
    'pkill', '--full', '--uid', os.getenv('USER'), '^pactl subscribe'
}, function()
    -- Run emit_volume_info() with each line printed
    awful.spawn.with_line_callback(volume_script, {
        stdout = function(line) emit_volume_info() end
    })
end)
emit_volume_info(true)
