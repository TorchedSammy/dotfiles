lunacolors = require 'lunacolors'
bait = require 'bait'
commander = require 'commander'

function doPrompt(fail)
	local res = io.popen 'git rev-parse --abbrev-ref HEAD 2> /dev/null'
	local branch = res:read()
	res:close()

	prompt(lunacolors.format(
		'{blue}in %D' .. (branch and ' {cyan}at {bold} ' .. branch or "") .. "\n" ..
		'{reset}{green}%h ' .. (fail and '{red}' or '{green}') .. '∆ '
	))
end

print(lunacolors.format('Welcome {cyan}'.. hilbish.user ..
'{reset} to {magenta}Hilbish{reset},\n' .. 
'the nice lil shell for {blue}Lua{reset} fanatics!\n'))

doPrompt()

bait.catch('command.exit', function(code)
	doPrompt(code ~= 0)
end)

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

commander.register('nvmnode', function()
	exec('sh -c "export NVM_DIR="$HOME/.nvm"'
	.. '; [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"' 
	.. '; nvm use node; exec hilbish"')
end)

alias('cls', 'clear')
alias('gcd', 'git checkout dev')
alias('gcm', 'git checkout master')

petals = require 'petals'
petals.init()

os.execute 'tty >/tmp/tty 2>&1'
local f = io.open '/tmp/tty'
local tty = f:read '*all'
tty = tty:gsub('\n', '')
f:close()

os.setenv('GPG_TTY', tty)
os.execute 'gpgconf --launch gpg-agent'

appendPath '~/.cargo/bin'
