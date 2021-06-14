lunacolors = require 'lunacolors'
bait = require 'bait'
commander = require 'commander'
delta = require 'delta'
fs = require 'fs'

print(lunacolors.format('Welcome {cyan}'.. hilbish.user ..
'{reset} to {magenta}Hilbish{reset},\n' .. 
'the nice lil shell for {blue}Lua{reset} fanatics!\n'))

delta.init()

commander.register('ver', function()
	print(hilbish.ver)
end)

commander.register('ev', function()
	text = ''
	while true do
		input = io.read()
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

-- Petals
petals = require 'petals'
petals.init()

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
	local d = args[1]
	local f = io.popen('jump cd ' .. d)
	local expdir = f:read '*all'
	f:close()

	fs.cd(expdir)
	bait.throw('cd', expdir)

	return 0
end)

