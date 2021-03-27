-- Default Hilbish config
ansikit = require 'ansikit'

os.setenv('PATH', os.getenv 'PATH' .. ':' .. os.getenv 'HOME' .. '/bin:/usr/local/go/bin')
prompt(ansikit.text(
	'{blue}%u {cyan}%d {green}∆{reset} '
))

--hook("tab complete", function ())
