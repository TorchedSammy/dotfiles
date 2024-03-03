local core = require 'core'
local command = require 'core.command'
local config = require 'core.config'

local ok = pcall(require, 'plugins.miq')
if not ok then
	core.log 'Installing Miq...'
	local proc = process.start {'git', 'clone', 'https://github.com/TorchedSammy/Miq', USERDIR .. '/plugins/miq'}
	if proc then
		proc:wait(process.WAIT_INFINITE)
		if proc:returncode() == 0 then
			command.perform 'core:restart'
		else
			print(proc:read_stdout() or proc:read_stderr())
			core.error 'Could not install Miq.'
		end
	end
end

config.plugins.miq.debug = true
config.plugins.miq.plugins = {
	-- miq can manage itself
	'~/Files/Projects/Miq',

	'TorchedSammy/Feathertime',

	{'TorchedSammy/Litepresence', run = 'go get && go build'},

	{
		'~/Files/Projects/Evergreen.lxl',
		--run = 'luarocks install ltreesitter --local --dev'
	},

	--{'TorchedSammy/lite-xl-gitdiff-highlight', name = 'gitdiff_highlight'},
	'~/Files/Projects/lite-xl-scm',

	'lite-xl/lite-xl-lsp',
	'TorchedSammy/lite-xl-lspkind',
	'~/Files/Projects/lspinstall.lxl',

	-- others
	'anthonyaxenov/lite-xl-ignore-syntax',
--	'juliardi/lite-xl-treeview-extender',
	'liquidev/lintplus',
}
