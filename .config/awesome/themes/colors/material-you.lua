local GLib = require 'lgi'.GLib

return function(wallpaper)
	local awful = require 'awful'

	local out = GLib.spawn_sync('.', {'matugen', 'image', wallpaper, '-j', 'hex'}, nil, GLib.SpawnFlags.SEARCH_PATH, 'sex')
	local obj = load('return ' .. out:gsub('("[^"]-"):', '[%1]='))()
	local colors = obj.colors.dark

	return {
		foreground = colors.on_surface,

		background = colors.surface,
		backgroundSecondary = colors.surface_container,
		backgroundTertiary = colors.surface_container_high,
		backgroundQuad = colors.surface_container_highest,

		containerLowest = colors.surface_container_lowest,
		containerLow = colors.surface_container_low,
		container = colors.surface_container,
		containerHigh = colors.surface_container_high,
		containerHighest = colors.surface_container_highest,

		containerSecondary = colors.secondary_container,
		containerSecondaryFg = colors.on_secondary_container,

		secondary = colors.secondary,
		secondaryFg = colors.on_secondary,

		accent = colors.primary,
		accentforeground = colors.on_primary,
		accentcontainer = colors.primary_container,

		separator = colors.outline_variant
	}
end

