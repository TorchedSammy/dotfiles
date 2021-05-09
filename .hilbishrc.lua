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

print(lunacolors.format('Welcome {cyan}'.. _user ..
'{reset} to {magenta}Hilbish{reset},\n' .. 
'the nice lil shell for {blue}Lua{reset} fanatics!\n'))

doPrompt()

bait.catch('command.exit', function(code)
	doPrompt(code ~= 0)
end)

commander.register('ver', function()
	print(_ver)
end)

commander.register('ev', function()
	text = ''
	while true do
		input = io.read()
		if input == nil then break end
		text = text .. '\n' .. input
	end
	(loadstring(text))()
end)

alias('cls', 'clear')
alias('gcd', 'git checkout dev')
alias('gcm', 'git checkout master')

petals = require 'petals'
petals.init()
