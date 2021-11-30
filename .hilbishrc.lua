lunacolors = require 'lunacolors'
bait = require 'bait'
commander = require 'commander'
delta = require 'delta'
fs = require 'fs'

print(lunacolors.format('Welcome {cyan}'.. hilbish.user ..
'{reset} to {magenta}Hilbish{reset},\n' ..
'the nice lil shell for {blue}Lua{reset} fanatics!\n'))

delta.init()

prependPath '~/bin/'
appendPath '/usr/local/go/bin/'
appendPath '~/go/bin/'

commander.register('ver', function()
	print(hilbish.ver)
end)

commander.register('ev', function()
	local text = ''
	while true do
		local input = io.read()
		if input == nil then break end
		text = text .. '\n' .. input
	end

	local ok, err = pcall(function() (loadstring(text))() end)
	if not ok then
		print(err)
		return 1
	end

	return 0
end)

-- Aliases
alias('cls', 'clear')
alias('gcd', 'git checkout dev')
alias('gcm', 'git checkout master')
alias('gmm', 'git merge master')
alias('gmd', 'git merge dev')
alias('ga', 'git add')
alias('gm', 'git merge')
alias('p', 'git push')
alias('c', 'git commit')

-- GPG
os.execute 'tty >/tmp/tty 2>&1'
local f = io.open '/tmp/tty'
local tty = f:read '*all'
tty = tty:gsub('\n', '')
f:close()

os.setenv('GPG_TTY', tty)
os.execute 'gpgconf --launch gpg-agent'

-- Cargo
appendPath '~/.cargo/bin'

-- Setup Volta
os.setenv('VOLTA_HOME', os.getenv 'HOME' .. '/.volta')
appendPath(os.getenv 'VOLTA_HOME' .. '/bin')

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
	local out = io.popen('jump cd ' .. d)
	local expdir = out:read '*all'
	out:close()

	fs.cd(expdir)
	bait.throw('cd', expdir)

	return 0
end)

