local M = {
	list = {}
}

function M.add(args)
	assert(args.name, 'Name is required for a command')
	assert(args.action, 'Action callback is required for a command')

	M.list[args.name] = args
end

function M.get(name)
	return M.list[name]
end

function M.defaults()
	for _, name in ipairs {
		'client'
	} do
		require('sys.command.' .. name)
	end
end

return M