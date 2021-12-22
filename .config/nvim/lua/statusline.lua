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
  yellow = c(tc.yellow),
  cyan = c(tc.cyan),
  green = c(tc.green),
  orange = c(tc.yellow),
  magenta = c(tc.magenta),
  blue = c(tc.blue),
  red = c(tc.red)
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
        t = 'TERMINAL',
        s = 'SNIPPET'
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
      require 'galaxyline.providers.fileinfo'.get_file_icon_color,
      colors.section_bg
    }
  }
},
{
  FileName = {
    provider = function ()
    	local fileinfo = require 'galaxyline.providers.fileinfo'
    	-- get file name and remove space at the end
    	-- galaxyline is kinda dumb and having this extra space with the separator is annoying
    	local fileName = string.gsub(fileinfo.get_current_file_name(), '^%s*(.-)%s*$', '%1')

		if fileName == '[packer]' then
			fileName = 'Packer'
		end

   		local gps = require 'nvim-gps'
    	local crumbs = ''
		if gps.is_available() then
    		if gps.get_location() ~= '' then
				crumbs = ' > ' .. gps.get_location()
			end
		end

    	return fileName .. crumbs
    end,
    separator = ' ',
    separator_highlight = {colors.section_bg, colors.section_bg},
    highlight = {colors.fg, colors.section_bg},
  }
},
{
  DiagnosticError = {
    provider = 'DiagnosticError',
    icon = '  ',
    highlight = {colors.red, colors.bg}
  }
}, {
  DiagnosticWarn = {
    provider = 'DiagnosticWarn',
    icon = '  ',
    highlight = {colors.orange, colors.bg}
  }
}, {
  DiagnosticHint = {
    provider = 'DiagnosticHint',
    icon = '  ',
    highlight = {colors.fg, colors.bg}
  }
}, {
  DiagnosticInfo = {
    provider = 'DiagnosticInfo',
    icon = '  ',
    highlight = {colors.blue, colors.bg},
  }
}}

gls.right = {
{
  GitIcon = {
    provider = function() return '  ' end,
    condition = function()
		local vcs = require 'galaxyline.providers.vcs'
		return vcs.get_git_branch() ~= nil
    end,
    highlight = {colors.red, colors.bg}
  }
},
{
  GitBranch = {
    provider = function()
      local vcs = require 'galaxyline.providers.vcs'
      local branch_name = vcs.get_git_branch()
      return branch_name .. ' '
    end,
    condition = function()
		local vcs = require 'galaxyline.providers.vcs'
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
     provider = function()
     	 local fileinfo = require 'galaxyline.providers.fileinfo'
     	 -- i hate the default lineinfo formatting
     	 return vim.fn.line '.' .. ':' .. vim.fn.col '.' .. ' ' .. fileinfo.current_line_percent()
     end,
     highlight = {colors.fg, colors.section_bg},
     separator = ' ',
     separator_highlight = {colors.bg, colors.section_bg},
   },
 },
 {
   Heart = {
     provider = function() return '  ' end,
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

