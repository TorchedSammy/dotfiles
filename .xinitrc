#! /bin/hilbish

-- invoke global X session script
os.execute 'xrandr --output LVDS-1 --panning 1920x1080 --scale 1.406x1.406 --output HDMI-1 --mode 1920x1080 --pos 1920x0'
exec 'awesome'
