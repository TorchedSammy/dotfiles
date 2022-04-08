local lunacolors = require 'lunacolors'
local bait = require 'bait'
local commander = require 'commander'
local delta = require 'delta'
local fs = require 'fs'

print(lunacolors.format(hilbish.greeting))

delta.init()

hilbish.prependPath '~/bin/'
hilbish.appendPath '/usr/local/go/bin/'
hilbish.appendPath '~/go/bin/'
hilbish.appendPath '~/.local/bin/'

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

-- GPG
local _, tty = hilbish.run('tty', false)
tty = tty:gsub('\n', '')

os.setenv('GPG_TTY', tty)
os.execute 'gpgconf --launch gpg-agent'

-- Cargo
hilbish.appendPath '~/.cargo/bin'

-- Setup Volta
os.setenv('VOLTA_HOME', os.getenv 'HOME' .. '/.volta')
hilbish.appendPath(os.getenv 'VOLTA_HOME' .. '/bin')

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

