local gl = require 'galaxyline'
local condition = require 'galaxyline.condition'
local tc = require 'themecolor'
local c = function(hex) return '#' .. hex end

local gls = gl.section
gl.short_line_list = {'NvimTree'}

local colors = {
  bg = c(tc.bgli),
  fg = c(tc.fg),
  section_bg = c(tc.bgvli),
  yellow = c(tc.gui3),
  cyan = c(tc.gui6),
  green = c(tc.gui2),
  orange = c(tc.gui3),
  magenta = c(tc.gui5),
  blue = c(tc.gui4),
  red = c(tc.gui1)
}

local mode_color = function()
  local mode_colors = {
    n = colors.blue,
    i = colors.green,
    c = colors.yellow,
    t = colors.green,
    R = colors.magenta,
    V = colors.cyan,
    v = colors.cyan,
    [''] = colors.cyan
  }

  local color = mode_colors[vim.fn.mode()]

  if color == nil then color = colors.red end

  return color
end

gls.left = {
{
	Space = {
		provider = function() return ' ' end,
		highlight = {colors.bg, colors.bg}
	}	
},
{
  ViMode = {
    provider = function()
      local alias = {
        n = 'NORMAL',
        i = 'INSERT',
        c = 'COMMAND',
        V = 'VISUAL',
        [''] = 'VISUAL',
        v = 'VISUAL',
        R = 'REPLACE',
        t = 'TERMINAL'
      }
      vim.api.nvim_command('hi GalaxyViMode guibg=' .. mode_color())
      local alias_mode = alias[vim.fn.mode()]
      if alias_mode == nil then alias_mode = vim.fn.mode() end
      return '  ' .. alias_mode .. ' '
    end,
    highlight = {colors.bg, colors.bg},
    separator = ' ',
    separator_highlight = {colors.section_bg, colors.section_bg}
  }
},
{
  FileIcon = {
    provider = 'FileIcon',
    highlight = {
      require 'galaxyline.provider_fileinfo'.get_file_icon_color,
      colors.section_bg
    }
  }
},
{
  FileName = {
    provider = 'FileName',
    highlight = {colors.fg, colors.section_bg},
  }
},
{
	Breadcrumbs = {
		provider = function()
			local gps = require 'nvim-gps'
			local location = ''
			if gps.get_location() ~= '' then
				location = '> ' .. gps.get_location()
			end
			return location
		end,
		condition = function()
			local gps = require 'nvim-gps'
			return gps.is_available()
		end,
		highlight = {colors.fg, colors.section_bg},
	}
},
{
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = ' ',
    highlight = {colors.red, colors.bg}
  }
}, {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = ' ',
    highlight = {colors.orange, colors.bg}
  }
}, {
  DiagnosticHint = {
    provider = 'DiagnosticHint',
    icon = ' ',
    highlight = {colors.fg, colors.bg}
  }
}, {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = ' ',
    highlight = {colors.blue, colors.bg},
    separator = ' ',
    separator_highlight = {colors.bg, colors.bg}
  }
}}

gls.right = {
{
  GitIcon = {
    provider = function() return '  ' end,
    condition = function()
		local vcs = require 'galaxyline.provider_vcs'
		return vcs.get_git_branch() ~= nil
    end,
    highlight = {colors.red, colors.bg}
  }
},
{
  GitBranch = {
    provider = function()
      local vcs = require 'galaxyline.provider_vcs'
      local branch_name = vcs.get_git_branch()
      return branch_name .. ' '
    end,
    condition = function()
		local vcs = require 'galaxyline.provider_vcs'
		return vcs.get_git_branch() ~= nil
    end,
    highlight = {colors.fg, colors.bg}
  }
},
{
  DiffAdd = {
    provider = 'DiffAdd',
    condition = condition.check_git_workspace,
    icon = '+',
    highlight = {colors.green, colors.bg}
  }
},
{
  DiffModified = {
    provider = 'DiffModified',
    condition = condition.check_git_workspace,
    icon = '~',
    highlight = {colors.orange, colors.bg}
  }
},
{
  DiffRemove = {
    provider = 'DiffRemove',
    condition = condition.check_git_workspace,
    icon = '-',
    highlight = {colors.red, colors.bg}
  }
}, 
{
   LineInfo = {
     provider = 'LinePercent',
     highlight = {colors.fg, colors.section_bg},
     separator = '█',
     separator_highlight = {colors.bg, colors.section_bg},
   },
 },
 {
   Heart = {
     provider = function() return ' ' end,
     highlight = {colors.red, colors.section_bg},
     separator = ' ',
     separator_highlight = {colors.bg, colors.section_bg},
   }
}}

-- inactive line
gls.short_line_left = {
{
	Space = {
		provider = function() return ' ' end,
		highlight = {colors.bg, colors.bg}
	}	
},
{
  BufferType = {
    provider = 'FileTypeName',
    highlight = {colors.fg, colors.section_bg},
    separator = ' ',
    separator_highlight = {colors.section_bg, colors.bg}
  }
}}

gls.short_line_right[1] = {
  BufferIcon = {
    provider = 'BufferIcon',
    highlight = {colors.yellow, colors.section_bg},
    separator = ' ',
    separator_highlight = {colors.section_bg, colors.bg}
  }
}

gl.load_galaxyline()

