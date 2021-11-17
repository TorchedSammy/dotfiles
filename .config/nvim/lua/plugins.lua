return require('packer').startup(function(use)
	-- Packer is stupid so i have to have it here too
	use 'wbthomason/packer.nvim'

	-- Buffer line
	-- Might replace with nvim-bufferline
	use {'romgrk/barbar.nvim', requires = 'kyazdani42/nvim-web-devicons'}

	use {'kyazdani42/nvim-tree.lua',
		config = function()
			require 'nvim-tree'.setup {
				auto_close = true,
				open_on_setup = true,
				update_cwd = true,
				diagnostics = {
				    enable = true,
				},
				update_focused_file = {
					enable = true,
				},
				filters = {
					custom = {'.git', 'node_modules'}
				},
				view = {
					width = 24,
					auto_resize = true
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

	-- Completions
	use 'L3MON4D3/LuaSnip'

	use {'hrsh7th/nvim-cmp',
		requires = {
			-- LSP things
			'neovim/nvim-lspconfig',
			'kabouzeid/nvim-lspinstall',
			'onsails/lspkind-nvim', -- icons
			-- Sources
			'hrsh7th/cmp-nvim-lsp', -- lsp
			'hrsh7th/cmp-path', -- file paths
			'hrsh7th/cmp-buffer',
			'saadparwaiz1/cmp_luasnip'
		},
		config = function()
			local cmp = require 'cmp'
			local luasnip = require 'luasnip'
			local lspkind = require 'lspkind'

			cmp.setup {
				snippet = {
					expand = function(args)
						require 'luasnip'.lsp_expand(args.body)
					end
				},
				formatting = {
					format = lspkind.cmp_format({with_text = false, maxwidth = 50})
				},
				sources = {
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'buffer' },
					{ name = 'path' }
				},
				mapping = {
					['<CR>'] = cmp.mapping.confirm {select = true},
					['Tab'] = function(cb)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							cb()
						end
					end,
					['<S-Tab>'] = function(cb)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							cb()
						end
					end,
					['<Esc>'] = function()
						if cmp.visible() then
							cmp.close()
						else
							vim.cmd 'stopinsert'
						end
					end,
					['<C-Esc>'] = function ()
						vim.cmd 'stopinsert'
					end
				}
			}
		end
	}

	use {'glepnir/galaxyline.nvim', branch = 'main',
		config = function()
			require 'statusline'
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
				log_level = 'error',
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

	use {'rcarriga/nvim-notify',
		config = function()
			vim.notify = require 'notify'
		end
	}

	-- i have copilot pog
	use 'github/copilot.vim'

	use{'SmiteshP/nvim-gps',
		config = function()
			require 'nvim-gps'.setup {}
		end
	}
end)
