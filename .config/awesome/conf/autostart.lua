local awful = require 'awful'
local beautiful = require 'beautiful'
local naughty = require 'naughty'

awful.spawn 'xmodmap -e "pointer = 3 2 1"'
-- Picom
awful.spawn.with_shell('picom --config ~/.config/picom/' .. beautiful.picom_conf
.. '.conf ' .. (beautiful.exp_picom_bknd and '--experimental-backends ' or '')
.. '-b')