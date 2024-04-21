local color = require 'modules.color'
local colors = {}

colors.name = 'stardew-night'
colors.xbackground = '#16161a'
colors.xforeground = '#DCDFE4'
colors.xcolor0  = '#16161a'
colors.xcolor1  = '#f25c5c'
colors.xcolor2  = '#55b682'
colors.xcolor3  = '#ff9c6a'
colors.xcolor4  = '#7aaaff'
colors.xcolor5  = '#f17ac6'
colors.xcolor6  = '#B87AFF'
colors.xcolor7  = '#e9ecf2'
colors.xcolor8  = '#212126'
colors.xcolor9  = '#2a2a30'
colors.xcolor10 = '#373740'
colors.xcolor11 = '#4f4f5c'
colors.xcolor12 = '#676778'
colors.xcolor13 = '#212126'
colors.xcolor14 = '#9595ab'
colors.xcolor15 = '#18181c'

colors.foreground = colors.xforeground

colors.background = colors.xbackground
colors.backgroundSecondary = colors.xcolor8
colors.backgroundTertiary = colors.xcolor9
colors.backgroundQuad = colors.xcolor10

colors.containerLowest = color.shift(colors.xbackground, -5)
colors.containerLow = colors.xbackground
colors.container = colors.backgroundSecondary
colors.containerHigh = colors.backgroundTertiary
colors.containerHighest = colors.backgroundQuad

colors.background2 = colors.background

colors.containerSecondary = colors.backgroundSecondary
colors.containerSecondaryFg = colors.xforeground

colors.accent = colors.xcolor6
colors.accentforeground = colors.xcolor0
colors.accentcontainer = colors.accent

colors.secondary = colors.containerSecondary
colors.secondaryFg = colors.xforeground

colors.separator = colors.backgroundTertiary

return colors
