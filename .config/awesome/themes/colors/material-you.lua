local GLib = require 'lgi'.GLib

return function(wallpaper)
	local awful = require 'awful'

	local out = GLib.spawn_sync('.', {'matugen', 'image', wallpaper, '-j', 'hex'}, nil, GLib.SpawnFlags.SEARCH_PATH, 'sex')
	local obj = load('return ' .. out:gsub('("[^"]-"):', '[%1]='))()
	local colors = obj.colors.dark

	return {
		background = colors.surface,
		backgroundSecondary = colors.surface_container,
		backgroundTertiary = colors.surface_container_high,
		backgroundQuad = colors.surface_container_highest,

		background2 = colors.surface_container_lowest,
		background3 = colors.surface_container_low,
		background4 = colors.surface_container,
		background5 = colors.surface_container_high,
		background6 = colors.surface_container_highest,
		foreground = colors.on_surface,

		accent = colors.primary,
		accentforeground = colors.on_primary,
		accentcontainer = colors.primary_container,

		separator = colors.outline_variant
	}
end

