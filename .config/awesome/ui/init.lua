local beautiful = require 'beautiful'

require('ui.bars.' .. (beautiful.bar and beautiful.bar or 'default'))
require('ui.titlebars.'
.. (beautiful.titlebar_type and beautiful.titlebar_type or 'default'))
require 'ui.notifs'
require 'ui.menu'

