local awful = require 'awful'
local bling = require 'modules.bling'

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

terminal = 'alacritty'
terminalname = terminal:gsub('^%l', string.upper)

editor = os.getenv 'EDITOR' or 'nvim'
editorname = 'Neovim'
editorcmd = terminal .. ' -e ' .. editor

musicplayer = 'cmus'
playername = musicplayer:gsub('^%l', string.upper)
musiccmd = terminal .. ' -e ' .. musicplayer

browsername = 'Google Chrome'
browsercmd = 'google-chrome'

modkey = 'Mod4'
altkey = 'Mod1'
shift = 'Shift'
control = 'Control'

bling.signal.playerctl.enable {
    backend = 'playerctl_lib',
    update_on_activity = true
}

require 'conf.keys'

