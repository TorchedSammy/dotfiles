local bait = require 'bait'
local commander = require 'commander'
local promptua = require 'promptua'
local fs = require 'fs'

promptua.setTheme 'delta'
promptua.init()

local _, tty = hilbish.run('tty', false)
tty = tty:gsub('\n', '')
os.setenv('GPG_TTY', tty)
hilbish.run 'gpgconf --launch gpg-agent'

os.setenv('LITE_SCALE', '0.9')
os.setenv('VOLTA_HOME', string.format('%s/volta', hilbish.userDir.data))
os.setenv('WINEPREFIX', string.format('%s/wine', hilbish.userDir.data))
os.setenv('RUSTUP_HOME', string.format('%s/rustup', hilbish.userDir.data))
os.setenv('GOPATH', string.format('%s/go', hilbish.userDir.data))
os.setenv('CARGO_HOME', string.format('%s/cargo', hilbish.userDir.data))
os.setenv('ANDROID_HOME', string.format('%s/android', hilbish.userDir.data))

os.setenv('INPUTRC', string.format('%s/readline/inputrc', hilbish.userDir.config))
os.setenv('GTK2_RC_FILES', string.format('%s/gtk-2.0/gtkrc', hilbish.userDir.config))
os.setenv('_JAVA_OPTIONS', string.format('-Djava.util.prefs.userRoot=%s/java', hilbish.userDir.config))

os.setenv('ERRFILE', string.format('%s/.cache/X11/xsession-errors', hilbish.home))
os.setenv('XAUTHORITY', string.format('%s/Xauthority', os.getenv 'XDG_RUNTIME_DIR'))

hilbish.prependPath '~/bin/'
hilbish.appendPath '/usr/local/go/bin/'
hilbish.appendPath(os.getenv 'VOLTA_HOME' .. '/bin')
hilbish.appendPath(os.getenv 'GOPATH' .. '/bin')
hilbish.appendPath(os.getenv 'CARGO_HOME' .. '/bin')
hilbish.appendPath '~/.local/bin/'
hilbish.appendPath '~/flutter/bin'
hilbish.appendPath '-/Android/Sdk/cmdline-tools/latest/bin'

commander.register('ver', function()
	print(hilbish.ver)
end)

commander.register('ev', function()
	local text = ''
	while true do
		local input = hilbish.read('*>')
		if input == nil then break end
		text = text .. '\n' .. input
	end

	local fn, err = load(text)
	if err then
		print(err)
		return 1
	end
	fn()

	return 0
end)

-- Aliases
hilbish.alias('cls', 'clear')
hilbish.alias('gcd', 'git checkout dev')
hilbish.alias('gcm', 'git checkout master')
hilbish.alias('gmm', 'git merge master')
hilbish.alias('gmd', 'git merge dev')
hilbish.alias('ga', 'git add')
hilbish.alias('gm', 'git merge')
hilbish.alias('p', 'git push')
hilbish.alias('c', 'git commit')
hilbish.alias('multimc', '~/MultiMC/MultiMC -d ~/.local/share/multimc > /dev/null 2>&1 &')

-- Setup jump (https://github.com/gsamokovarov/jump)
bait.catch('cd', function()
	os.execute 'jump chdir'
end)

commander.register('j', function(args)
	if not args[1] then
		print 'missing dir to jump to'
		return 1
	end

	local d = args[1]
	local _, expdir = hilbish.run('jump cd ' .. d, false)

	fs.cd(expdir)
	bait.throw('cd', expdir)

	return 0
end)

