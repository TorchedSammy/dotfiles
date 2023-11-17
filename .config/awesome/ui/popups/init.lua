local beautiful = require 'beautiful'
local settings = require 'conf.settings'

require('ui.popups.' .. settings.theme)
--local ok, popups = pcall(require, )
--if not ok then return end -- TODO: print error (check if the path doesnt exist ig)
