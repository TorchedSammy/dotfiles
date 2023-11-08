local beautiful = require 'beautiful'

require('ui.bars.' .. (beautiful.bar and beautiful.bar or 'default'))
require 'ui.titlebars'
require 'ui.notifs'
require 'ui.menu'

