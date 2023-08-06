local awful = require 'awful'
local beautiful = require 'beautiful'
local gfs = require 'gears.filesystem'
local settings = require 'conf.settings'
local bling = require 'libs.bling'
local json = require 'libs.json'

local f = io.open(gfs.get_xdg_data_home() .. 'awesome-config.json')
beautiful.init('~/.config/awesome/themes/' .. settings.theme .. '.lua')

awful.layout.layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.spiral.dwindle,
	awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
--	awful.layout.suit.tile.left,
--	awful.layout.suit.tile.bottom,
--	awful.layout.suit.tile.top,
--	awful.layout.suit.fair,
--	awful.layout.suit.fair.horizontal,
--	awful.layout.suit.spiral,
--	awful.layout.suit.max,
--	awful.layout.suit.corner.nw,
--	awful.layout.suit.corner.ne,
--	awful.layout.suit.corner.sw,
--	awful.layout.suit.corner.se,
}

require 'conf.autostart'

terminal = 'tym'
terminalname = terminal:gsub('^%l', string.upper)

editor = 'lite-xl'
editorname = 'Lite XL'
editorcmd = editor

musicplayer = 'cmus'
playername = musicplayer:gsub('^%l', string.upper)
musiccmd = terminal .. ' -e ' .. musicplayer

browsername = 'Google Chrome'
browsercmd = 'google-chrome'

modkey = 'Mod4'
altkey = 'Mod1'
shift = 'Shift'
control = 'Control'

require 'conf.keys'
require 'conf.signals'

