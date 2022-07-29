#! /bin/hilbish

hilbish.run 'source /etc/X11/xinit/xinitrc-common'
os.execute 'xrandr --output LVDS --panning 1920x1080 --scale 1.406x1.406 --output HDMI-0 --mode 1920x1080 --pos 1920x0'

hilbish.exec 'awesome'
