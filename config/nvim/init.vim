call plug#begin(stdpath('data') . '/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'airblade/vim-gitgutter'
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin' |
            \ Plug 'ryanoasis/vim-devicons'
Plug 'ryanoasis/vim-devicons'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-fugitive'
Plug 'roryokane/detectindent'

call plug#end()

" Neovim stuff
set number

" COC
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" # Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " # Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " # Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" # Remap keys for applying codeAction to the current buffer.
nmap <leader>ga  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" # Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" # Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" # Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" GitGutter
highlight SignColumn guibg=0 ctermbg=0

" Lightline
set noshowmode
let g:lightline = {
      \ 'colorscheme': 'wombat',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename' ] ],
      \   'right': [ [ 'lineinfo' ],
      \              [ 'percent' ],
      \              [ 'fileencoding', 'filetype', 'charvaluehex' ] ]
      \ },
      \ 'component': {
      \   'charvaluehex': '0x%B'
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead',
      \   'filename': 'LightlineFilename'
      \ },
      \ }

function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction

" Nerdtree-git
let g:NERDTreeGitStatusUseNerdFonts = 1
