local beautiful = require 'beautiful'
local settings = require 'conf.settings'
local naughty = require 'naughty'

--require('ui.popups.' .. settings.theme)
local ok, panel = pcall(require, 'ui.panels.notifications.' .. settings.theme)
if not ok then error(panel) end

return panel
--if not ok then return end -- TODO: print error (check if the path doesnt exist ig)
