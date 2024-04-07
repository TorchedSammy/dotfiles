local lgi = require 'lgi'
local Gio = lgi.Gio
local GLib = lgi.GLib
local gears = require 'gears'
local json = require 'libs.json'

local configDir = gears.filesystem.get_xdg_data_home() .. 'awesome/'
Gio.File.new_for_path(configDir):make_directory()

local configPath = configDir .. 'config.json'
local file = Gio.File.new_for_path(configPath)

local config = {
	theme = 'harmony',
	picom = true,
	noAnimate = false
}

local M = {}

if not gears.filesystem.file_readable(configPath) then
	file:create_async(Gio.FileCreateFlags.NONE, GLib.PRIORITY_DEFAULT, nil, function(_, res)
		local stream = file:create_finish(res)
		local encoded = json.encode(config)
		stream:write_async(encoded, GLib.PRIORITY_DEFAULT, nil, function(_, res) stream:write_finish(res) end)
	end)
else
	local content = file:load_contents()
	config = json.decode(content)
end

function M.write()
	file:replace_contents_bytes_async(GLib.Bytes(json.encode(config)), nil, false, Gio.FileCreateFlags.REPLACE_DESTINATION, nil, function(_, res) file:replace_contents_finish(res) end)
end

function M.set(key, val, write)
	config[key] = val
	if write then M.write() end
end

return setmetatable(M,  {
	__index = function(_, k)
		return config[k]
	end,
	__newindex = function(_, k, v)
		M.set(k, v, true)
	end
})
