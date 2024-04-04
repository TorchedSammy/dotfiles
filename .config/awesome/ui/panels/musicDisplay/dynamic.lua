local awful = require 'awful'
local beautiful = require 'beautiful'
local wibox = require 'wibox'
local helpers = require 'helpers'
local rubato = require 'libs.rubato'
local pctl = require 'modules.playerctl'
local music = require 'ui.panels.musicDisplay'
local harmony = require 'ui.components.harmony'
local gears = require 'gears'
local Color = require 'lua-color'
local w = require 'ui.widgets'

local albumArt = w.imgwidget('albumPlaceholder.png', {
    widget = wibox.widget.imagebox,
    horizontal_fit_policy = 'cover',
    vertical_fit_policy = 'cover',
    valign = 'center',
    halign = 'center',
})

local mw, width, height = music.new {
    bg = '#00000000',
    shape = helpers.rrect(16),
    fg_sec = beautiful.fg_normal,
}

local titlebar, titleHeight = harmony.titlebar 'Music'
local musicDisplay = wibox {
    width = beautiful.dpi(480),
    height = beautiful.dpi(180) + titleHeight,
    bg = '#00000000',
    ontop = true,
    visible = false
}

local titlebarColor = Color('#0f0f1f')
local _, titlebarColorSat, titlebarColorVal = titlebarColor:hsv()

local function makeGradient(solid, transparent)
    return {
        type  = 'linear' ,
        from  = {
            0,
            musicDisplay.height
        },
        to = {
            musicDisplay.width,
            musicDisplay.height
        },
        stops = {
            {
                0,
                solid
            },
            {
                0.3,
                solid .. 'e6'
            },
            {
                0.5,
                solid .. '99'
            },
            {
                0.7,
                solid .. 'cc'
            },
            {
                0.9,
                solid .. 'e6'
            },
            {
                1,
                solid
            }
        }
    }
end
local gradient = wibox.widget {
    widget = wibox.container.background,
    bg = makeGradient(beautiful.bg_sec, beautiful.bg_sec)
}

local oldMusicColors = {
    gradient = Color(beautiful.bg_sec),
    shuffle = Color(beautiful.accent)
}

local albumColors = {}
local oldMetadata = {}
local expectedColors = 0
pctl.listenMetadata(function (title, artist, art, album)
    if oldMetadata.artist == artist and oldMetadata.album == album then return end

    oldMetadata.artist = artist
    oldMetadata.album = album

    albumArt.image = gears.surface.load_uncached_silently(art)
    albumColors = {}

    awful.spawn.with_line_callback(string.format('magick %s -colors 5 -unique-colors txt:', art), {
        stdout = function(out)
            local enumAmount = out:match 'ImageMagick pixel enumeration: (%d),'
            if enumAmount then expectedColors = tonumber(enumAmount) end

            local idx = tonumber(out:match '^%d')
            if not idx then return end
            idx = idx + 1

            albumColors[idx] = Color(out:match '#%x%x%x%x%x%x')

            if idx == expectedColors then
                local albumColorsValue = table.filter(albumColors, function(t)
                    -- only for the background gradient: attempt to avoid black/white if others are available
                    local _, s, v = t:hsv()
                    if (v * 100) < 15 or (s * 100) < 15 then
                        print(string.format('goodbye to the color that is %s', t))
                        return false
                    end
                    return true
                end)

                -- copy without reference to other table (to not mess up gradient)
                local albumColorsLight = {}
                --for k, v in pairs(albumColors) do albumColorsLight[k] = v end
                if #albumColorsValue > 3 then
                    for k, v in pairs(albumColorsValue) do albumColorsLight[k] = v end
                else
                    for k, v in pairs(albumColors) do albumColorsLight[k] = v end
                end
                table.sort(albumColorsLight, function(c1, c2)
                    local _, _, l1 = c1:hsla()
                    local _, _, l2 = c2:hsla()

                    return l1 > l2
                end)

                -- TODO: next sort by color value?

                local gradientColor = albumColors[1]
                if #albumColorsValue > 4 then
                    gradientColor = albumColorsValue[1]
                end
                local shuffleColor
                if #albumColorsValue > 2 then
                    local albmClrValHue, albmClrSat, albmClrLum = albumColorsLight[1]:hsla()
                    shuffleColor = Color {h = albmClrValHue, s = albmClrSat, v = (albmClrLum - 1) * -1}
                else
                    shuffleColor = beautiful.accent
                end

                local titlebarBg = titlebar:get_children_by_id'bg'[1]
                local animator = rubato.timed {
                    duration = 3,
                    rate = 60,
                    override_dt = false,
                    subscribed = function(perc)
                        local mixedColor = oldMusicColors.gradient:mix(gradientColor, perc / 100)
                        local mixedColorHue = mixedColor:hsv()
                        titlebarBg.bg = tostring(Color {h = mixedColorHue, s = titlebarColorSat, v = titlebarColorVal})
                        gradient.bg = makeGradient(tostring(mixedColor), beautiful.bg_sec)
                        mw.setColors {
                            --shuffle = tostring(oldMusicColors.shuffle:mix(shuffleColor, perc / 100))
                            --shuffle = helpers.invertColor(tostring(shuffleColor), true)
                            shuffle = shuffleColor
                        }

                        if perc == 100 then
                            oldMusicColors.gradient = gradientColor
                            oldMusicColors.shuffle = albumColors[3]
                        end
                    end,
                    pos = 0,
                    easing = {
                        F = 1/3, -- F(1) = 1/3
                        easing = function(t) return t*t end -- f(x) = x^2, I just use t for 'time'
                    }
                }
                if musicDisplay.displayed then
                    animator.target = 100
                else
                    local gradientColorHue = gradientColor:hsv()
                    titlebarBg.bg = tostring(Color {h = gradientColorHue, s = titlebarColorSat, v = titlebarColorVal})
                    gradient.bg = makeGradient(tostring(gradientColor), beautiful.bg_sec)
                    mw.setColors {
                        --shuffle = tostring(oldMusicColors.shuffle:mix(shuffleColor, perc / 100))
                        --shuffle = helpers.invertColor(tostring(shuffleColor), true)
                        shuffle = shuffleColor
                    }

                    oldMusicColors.gradient = gradientColor
                    oldMusicColors.shuffle = albumColors[3]
                end

                -- {{
                -- for now, this part is a bit meh and actually causes
                -- WORSE colors for the progress bar. funny huh, when the table is for
                -- colors with better values.
                local progressColors = {albumColors[3], albumColors[2]}
                if #albumColorsValue > 3 then
                    progressColors = {albumColorsValue[3], albumColorsValue[2]}
                end
                -- }}

                mw.setColors {
                    --position = helpers.invertColor(albumColors[1], true),
                    --album = helpers.invertColor(albumColors[1], true),
                    progress = {
                        tostring(albumColorsLight[1]),
                        tostring(albumColorsLight[2]),
                    }
                }
            end
        end,
        exit = function(reason, code)
            if reason == 'exit' and code == 0 then
            -- was doing the colors here but albumColors is length 0 for some reason (???)
            end
        end
    })
end)

musicDisplay:setup {
    widget = wibox.container.background,
    shape = helpers.rrect(beautiful.radius),
    {
        layout = wibox.layout.fixed.vertical,
        titlebar,
        {
            layout = wibox.layout.stack,
            --[[
				{
					widget = filters.blur,
					dual_pass = false,
					radius = 5,
					albumArt,
				},
				]]--
            albumArt,
            gradient,
            mw
        }
    }
}
helpers.slidePlacement(musicDisplay, {placement = 'bottom_right'})

return musicDisplay

