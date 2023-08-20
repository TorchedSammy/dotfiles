local awful = require 'awful'
local beautiful = require 'beautiful'
local hotkeys_popup = require 'awful.hotkeys_popup'
local has_fdo, freedesktop = false, nil

awesomemenu = {
	{
		'Hotkeys',
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end
	},
	{
		'Restart',
		awesome.restart
	},
	{
   	   'Quit',
   	   function()
			awesome.quit()
		end 
	}
}

local menu_awesome = {
	'Awesome',
	awesomemenu,
	beautiful.awesome_icon
}
local menuterminal = {
	terminalname,
	terminal
}
local menueditor = {
	editorname,
	editorcmd
}
local menuplayer = {
	playername,
	musiccmd
}
local menubrowser = {
	browsername,
	browsercmd
}

restmenu = {
	menuterminal,
	menueditor,
	menuplayer,
	menubrowser,
}

if has_fdo then
	mainmenu = freedesktop.menu.build {
		before = {
			menu_awesome
		},
		after = restmenu
	}
else
	mainmenu = awful.menu {
		items = {
			menu_awesome,
			table.unpack(restmenu)
		}
	}
end

launcher = awful.widget.launcher {
	image = beautiful.awesome_icon,
	menu = mainmenu
}

