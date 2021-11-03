return require('packer').startup(function(use)
	-- Packer is stupid so i have to have it here too
	use 'wbthomason/packer.nvim'

	-- Buffer line
	-- Might replace with nvim-bufferline
	use {'romgrk/barbar.nvim', requires = 'kyazdani42/nvim-web-devicons'}

	use {'kyazdani42/nvim-tree.lua',
		config = function()
			require'nvim-tree'.setup {
				open_on_setup = true,
				auto_close = true,
				update_cwd = true,
				diagnostics = {
				    enable = true,
				},
				update_focused_file = {
					enable      = true,
				},
				filters = {
					custom = {'.git', 'node_modules'}
				},
				view = {
					width = 24
				}
			}
		end
	}

	use {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'},
		config = function()
			require 'gitsigns'.setup {
				signs = {
					topdelete = {
						hl = 'GitSignsDelete',
						text = '-'
					},
					changedelete = {
						hl = 'GitSignsChange',
						text = '|'
					},
				}
			}
		end
	}

	use 'dstein64/nvim-scrollview'

	use {'hrsh7th/nvim-compe', requires = {'neovim/nvim-lspconfig', 'kabouzeid/nvim-lspinstall', 'hrsh7th/vim-vsnip'},
		config = function()
			require 'compe'.setup {
				enabled = true,
				autocomplete = true,
				min_length = 3,
				preselect = 'enable',
				source = {
					path = true,
					buffer = true,
					calc = true,
					nvim_lsp = true,
					nvim_lua = true,
					vsnip = true,
					ultisnips = true,
				}
			}
		end
	}

	use {'famiu/feline.nvim',
		config = function()
			require('feline').setup {
				preset = 'noicon'
			}
		end
	}

	use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate',
		config = function()
			require 'nvim-treesitter.configs'.setup {
				ensure_installed = {'lua', 'go'},
				highlight = {
					enable = true
				}
			}
		end
	}

	use 'jiangmiao/auto-pairs'

	use {'andweeb/presence.nvim',
		config = function()
			require 'presence':setup {
				auto_update	= true,
				neovim_image_text = 'The One True Text Editor',
				main_image = 'file',
				log_level = 'debug',
				debounce_timeout = 10,
				enable_line_number	= false,
				editing_text = 'Working on %s',
				file_explorer_text	= 'Browsing %s',
				git_commit_text = 'Committing Changes', 
				plugin_manager_text = 'Managing Plugins',
				reading_text = 'Looking at %s',
				workspace_text = 'Workspace: %s',
				line_number_text = 'Line %s/%s',
			}
		end
	}

	use {"folke/trouble.nvim", requires = "kyazdani42/nvim-web-devicons"}

	use {"folke/todo-comments.nvim", requires = "nvim-lua/plenary.nvim"}
end)
