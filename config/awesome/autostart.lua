local awful = require('awful')

awful.spawn('xmodmap -e "pointer = 3 2 1"')
awful.spawn('picom -b')