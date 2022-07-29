local naughty = require 'naughty'
local settings = require 'conf.settings'

if package.searchpath('initialize.' .. settings.theme, package.path) then
	local ok, err = pcall(require, 'initialize.' .. settings.theme)
	if not ok then
		naughty.notify {
			preset = naughty.config.presets.critical,
			title = 'Error running theme-specific init code!',
			text = err
		}
	end
end
