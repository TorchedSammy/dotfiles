local tym = require 'tym'
local thm = dofile(tym.get_theme_path())

-- todo: watch config file and autoreload

tym.set('font', 'Victor Mono Nerd Font Medium 12')
tym.set_config {
	title = 'Tym',
	padding_horizontal = 20,
	padding_vertical = 16,
	cursor_shape = 'ibeam',
	color_window_background = thm.color_background,
	shell = [[hilbish -ic "os.setenv('SHLVL', tostring(tonumber(os.getenv 'SHLVL') - 1))"]]
}

tym.set_hook('selected', function ()
	tym.copy_selection()
end)
