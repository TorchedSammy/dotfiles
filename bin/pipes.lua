#! /bin/hilbish
-- this is broken
-- by broken, i mean it gets the wrong character to draw
-- if u can fix, please do ill love u forever
-- based on pipes script in https://github.com/TorchedSammy/dotfiles/blob/old/bin/pipes
function runcmd(cmd, giveout)
	local cmd = cmd:gsub("\\x(%x%x)",function (x) return string.char(tonumber(x,16)) end)
	if giveout then
		local f = io.popen(cmd)
		local output = f:read '*all'
		local out = output:gsub('\n', '')
		f:close()

		return out
	else
		os.execute(cmd)
	end
end

local f, s, r, t, c, n, l = 75, 13, 2000, 0, 1, 0, 0
local w = 80--tonumber(runcmd('tput cols', true))
local h = 24--tonumber(runcmd('tput lines', true))
local x = w / 2
local y = h / 2

-- UTF-8 box characters
local v = {
	[00]=[[\x82]],
	[01]=[[\x8c]],
	[03]=[[\x90]],
	[10]=[[\x98]],
	[11]=[[\x80]],
	[12]=[[\x90]],
	[21]=[[\x94]],
	[22]=[[\x82]],
	[23]=[[\x98]],
	[30]=[[\x94]],
	[32]=[[\x8c]],
	[33]=[[\x80]]
}

-- Heavy UTF-8 box characters
--[[
OPTIND=1
while getopts "f:s:r:h" arg; do
	case $arg in
	h) v=([00]=[[\x83" [01]=[[\x8f" [03]=[[\x93"
	      [10]=[[\x9b" [11]=[[\x81" [12]=[[\x93"
	      [21]=[[\x97" [22]=[[\x83" [23]=[[\x9b"
	      [30]=[[\x97" [32]=[[\x8f" [33]=[[\x81")
		;;
	f) ((f=(OPTARG>19 && OPTARG<101) ? OPTARG : f)) ;;
	s) ((s=(OPTARG>4  && OPTARG<16 ) ? OPTARG : s)) ;;
	r) ((r=(OPTARG>0) ? OPTARG : r)) ;;
	h) cat <<- EOF
		Usage: pipes [OPTION ...]
		 -f [20-100] framerate (Default: 13)
		 -s [5-15]   probability of a straight fitting (Default: 13)
		 -r limit    reset after limit characters (Default: 2000)
		 -h          show this
		EOF
		exit
		;;
	esac
done
]]--

runcmd 'tput smcup'
runcmd 'tput reset'
runcmd 'tput civis'

while true do
	-- New position:
	if l % 2 == 0 then x = x + (l == 1 and 1 or -1) end
	if not (l % 2 == 0) then y = y + (l == 2 and 1 or -1) end

	--  Loop on edges (change color on loop):
	c = ((x > w or x < 0 or y > h or y < 0) and math.random(0, 32767) % 7 or c)
	x = (x > w and 0 or (x < 0 and w or x))
	y = (y > h and 0 or (y < 0 and h or y))

	-- New random direction:
	n = (math.random(0, 32767) % (s - 1))
	n = ((n > 1 or n == 0) and l or l + n)
	n = (n < 0 and 3 or n % 4)

	-- Print:
--	print(v[tonumber(l .. n)])
	runcmd('tput cup ' .. y .. ' ' .. x)
	runcmd([[printf "\033[1;3%sm\xe2\x94%s]] .. v[tonumber(l .. n)] .. '" "' .. c .. '"')
	if t > r then
		runcmd 'tput reset && tput civis'
		t = 0
	else
		t = t + 1
	end
	l = n
	-- XXX: relies on decimal support in sleep
	runcmd('sleep "$(echo "scale=5;1/' .. f .. '"|bc)"')
end
