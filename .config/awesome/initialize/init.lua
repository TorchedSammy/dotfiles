local settings = require 'conf.settings'

pcall(require, 'initialize.' .. settings.theme)
