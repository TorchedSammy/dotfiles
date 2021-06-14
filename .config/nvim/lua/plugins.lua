return require('packer').startup(function(use)
	-- Packer is stupid so i have to have it here too
	use 'wbthomason/packer.nvim'

	-- Buffer line
	-- Might replace with nvim-bufferline
	use {'romgrk/barbar.nvim', requires = 'kyazdani42/nvim-web-devicons'}

	use 'kyazdani42/nvim-tree.lua'

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
end)
