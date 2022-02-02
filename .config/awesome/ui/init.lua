local beautiful = require 'beautiful'

require('ui.bars.' .. (beautiful.bar and beautiful.bar or 'default'))
if beautiful.titlebar_type ~= 'none' then
	require('ui.titlebars.' .. (beautiful.titlebar_type and beautiful.titlebar_type or 'default'))
end
require 'ui.notifs'
require 'ui.menu'

