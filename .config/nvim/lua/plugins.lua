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

	use 'neovim/nvim-lspconfig'
	use 'kabouzeid/nvim-lspinstall'

	use {'famiu/feline.nvim',
		config = function()
			require('feline').setup {
				preset = 'noicon'
			}
		end
	}
end)
