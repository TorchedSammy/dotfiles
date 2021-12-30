return require 'packer'.startup(function(use)
	-- Packer is stupid so i have to have it here too
	use 'wbthomason/packer.nvim'

	use 'lewis6991/impatient.nvim'

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
	use {
		'L3MON4D3/LuaSnip', requires = 'rafamadriz/friendly-snippets',
		config = function()
			require 'luasnip.loaders.from_vscode'.lazy_load {
				paths = { '~/.local/share/nvim/site/pack/packer/start/friendly-snippets' }
			}
		end
	}

	-- i have copilot pog
	use {'github/copilot.vim',
--		event = 'BufEnter',
		config = function ()
			vim.g.copilot_no_tab_map = true
			vim.g.copilot_assume_mapped = true
		end
	}

	use 'tami5/lspsaga.nvim'

	use {'hrsh7th/nvim-cmp',
		requires = {
			-- LSP things
			'neovim/nvim-lspconfig',
			'williamboman/nvim-lsp-installer',
			-- Sources
			'hrsh7th/cmp-nvim-lsp', -- lsp
			'hrsh7th/cmp-path', -- file paths
			'hrsh7th/cmp-buffer',
			'saadparwaiz1/cmp_luasnip'
		},
		config = function()
			local cmp = require 'cmp'
			local luasnip = require 'luasnip'
			local fn = vim.fn

			local function t(str)
				return vim.api.nvim_replace_termcodes(str, true, true, true)
			end

			local check_back_space = function()
				local col = vim.fn.col '.' - 1
				return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
			end

			local cmp_kinds = {
				Text = '  ',
				Method = '  ',
				Function = '  ',
				Constructor = '  ',
				Field = '  ',
				Variable = '  ',
				Class = '  ',
				Interface = '  ',
				Module = '  ',
				Property = '  ',
				Unit = '  ',
				Value = '  ',
				Enum = '  ',
				Keyword = '  ',
				Snippet = '  ',
				Color = '  ',
				File = '  ',
				Reference = '  ',
				Folder = '  ',
				EnumMember = '  ',
				Constant = '  ',
				Struct = '  ',
				Event = '  ',
				Operator = '  ',
				TypeParameter = '  ',
			}

			-- i hate lsp
			---@diagnostic disable-next-line: redundant-parameter
			cmp.setup {
				snippet = {
					expand = function(args)
						require 'luasnip'.lsp_expand(args.body)
					end
				},
				formatting = {
					fields = { 'abbr', 'kind' },
					format = function(_, item)
						item.kind = (cmp_kinds[item.kind] or '') .. item.kind
						return item
					end,
				},
				sources = {
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'buffer' },
					{ name = 'path' },
				},
				mapping = {
					['<Tab>'] = cmp.mapping(function (cb)
						if luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif cmp.visible() then
							cmp.select_next_item()
						elseif check_back_space() then
							fn.feedkeys(t '<tab>', 'n')
						else
							cb()
						end
					end, { 'i', 's' }),
					['<S-Tab>'] = cmp.mapping(function (cb)
						if luasnip.jumpable(-1) then
							luasnip.jump(-1)
						elseif cmp.visible() then
							cmp.select_prev_item()
						else
							cb()
						end
					end, { 'i', 's' }),
					['<Esc>'] = function()
						if cmp.visible() then
							cmp.close()
						else
							vim.cmd 'stopinsert'
						end
					end,
					['<C-Esc>'] = function () vim.cmd 'stopinsert' end,
					['<CR>'] = cmp.mapping.confirm {select = true},
				}
			}
		end
	}

	use {'CosmicNvim/galaxyline.nvim', branch = 'main',
		config = function()
			require 'statusline'
		end
	}

	use {'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate',
--		event = 'BufRead',
		config = function()
			require 'nvim-treesitter.configs'.setup {
				ensure_installed = {'lua', 'go'},
				highlight = {
					enable = true
				}
			}
		end
	}

	use {'windwp/nvim-autopairs',
		config = function()
			require 'nvim-autopairs'.setup{}
		end
	}

	use {'andweeb/presence.nvim',
--		event = 'BufRead',
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

	use {'folke/trouble.nvim', requires = 'kyazdani42/nvim-web-devicons'}

	use {'rcarriga/nvim-notify',
		config = function()
			vim.notify = require 'notify'
		end
	}

	use {'SmiteshP/nvim-gps',
		config = function()
			require 'nvim-gps'.setup {}
		end
	}

	use 'wakatime/vim-wakatime'

	use {'gbprod/cutlass.nvim',
		config = function()
			require 'cutlass'.setup {
				cut_key = 'd'
			}
		end
	}

	use {'nvim-telescope/telescope.nvim', requires = {'kyazdani42/nvim-web-devicons', 'nvim-lua/plenary.nvim'}}
end)
