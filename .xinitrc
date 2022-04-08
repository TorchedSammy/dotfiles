#! /bin/hilbish

os.execute 'xrandr --output LVDS --panning 1920x1080 --scale 1.406x1.406 --output HDMI-0 --mode 1920x1080 --pos 1920x0'

local _, auth = hilbish.run('gnome-keyring-daemon --start', false)
os.setenv('SSH_AUTH_SOCKET', string.split(auth, '=')[2])

hilbish.exec 'awesome'
