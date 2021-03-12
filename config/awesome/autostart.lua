local awful = require('awful')
local beautiful = require('beautiful')

awful.spawn('xmodmap -e "pointer = 3 2 1"')
-- TODO: Use experimental-backends if the picom config requires it
-- and don't make config based on theme, instead on what picom config works
-- well with theme (avoids duplicates, reduces amounts of config 
-- and adds more variety)
awful.spawn('picom -b --config '..os.getenv('HOME').."/.config/picom/picom"..(themename and '-'..themename or '')..'.conf')
