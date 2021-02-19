local awful = require('awful')
local beautiful = require('beautiful')

awful.spawn('xmodmap -e "pointer = 3 2 1"')
awful.spawn('picom -b --config '..os.getenv('HOME').."/.config/picom/picom"..(themename and '-'..themename or '')..'.conf')