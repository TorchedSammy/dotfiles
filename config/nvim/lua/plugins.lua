vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
	use 'wbthomason/packer.nvim'
	use { 'neoclide/coc.nvim', branch = 'release' }
	use { 'lewis6991/gitsigns.nvim',
		requires = { 'nvim-lua/plenary.nvim' },
	}
	use 'itchyny/lightline.vim'
	use { 'romgrk/barbar.nvim',
		requires = { 'kyazdani42/nvim-web-devicons' }
	}
	use { 'kyazdani42/nvim-tree.lua',
		requires = { 'kyazdani42/nvim-web-devicons' }
	}
	-- ///////
	use 'rstacruz/vim-closer'
	-- Autocloses braces and all that stuff 
	use 'tpope/vim-endwise'
	-- //////
	use 'b3nj5m1n/kommentary'
	use { 'iamcco/markdown-preview.nvim',
		run = ':call mkdp#util#install()'
	}
	-- Don't know if I need this anymore or not
	-- use 'tpope/vim-fugitive'
end)
