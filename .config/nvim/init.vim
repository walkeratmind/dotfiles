
set nocompatible              " be iMproved, required
filetype off                  " required

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vim-Plug
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin()



" => Aesthetics
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/vim-journal'
Plug 'junegunn/rainbow_parentheses.vim'

Plug 'morhetz/gruvbox'


" => Functionalities
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'ervandew/supertab'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/vim-easy-align'
Plug 'alvan/vim-closetag'
Plug 'tpope/vim-abolish'
Plug 'Yggdroot/indentLine'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'majutsushi/tagbar'

Plug 'chrisbra/Colorizer'
Plug 'KabbAmine/vCoolor.vim'
Plug 'vim-scripts/loremipsum'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'dkarter/bullets.vim'

" => Programming
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go', { 'do': 'make'}
Plug 'heavenshell/vim-pydocstring', { 'do': 'make install' }
Plug 'w0rp/ale'
Plug 'sheerun/vim-polyglot'

"*****************************************************************************
"" Custom bundles
"*****************************************************************************

" c
Plug 'vim-scripts/c.vim', {'for': ['c', 'cpp']}
Plug 'ludwig/split-manpage.vim'


" go
"" Go Lang Bundle
Plug 'fatih/vim-go', {'do': ':GoInstallBinaries'}


" javascript
"" Javascript Bundle
Plug 'jelera/vim-javascript-syntax'


" python
"" Python Bundle
Plug 'davidhalter/jedi-vim'
Plug 'raimon49/requirements.txt.vim', {'for': 'requirements'}
Plug 'metakirby5/codi.vim'


" rust
" Vim racer
Plug 'racer-rust/vim-racer'

" Rust.vim
Plug 'rust-lang/rust.vim'


" scala
if has('python')
    " sbt-vim
    Plug 'ktvoelker/sbt-vim'
endif
" vim-scala
Plug 'derekwyatt/vim-scala'


" typescript
Plug 'leafgarland/typescript-vim'
Plug 'HerringtonDarkholme/yats.vim'


" vuejs
Plug 'posva/vim-vue'
Plug 'leafOfTree/vim-vue-plugin'


" => Entertainment
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Plug 'ryanss/vim-hackernews'

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

colorscheme gruvbox

if has("gui_vimr")
  set background=light
  let g:gruvbox_contrast_light = 'hard'
else
  set background=dark
  let g:gruvbox_contrast_dark = 'soft'
endif


highlight Pmenu guibg=white guifg=black gui=bold
highlight Comment gui=bold
highlight Normal gui=none
highlight NonText guibg=none

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ==> Other Configurations
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab autoindent
set incsearch ignorecase smartcase hlsearch
set ruler laststatus=2 showcmd showmode
set list listchars=trail:»,tab:»-
set fillchars+=vert:\
set wrap breakindent
set encoding=utf-8
set number
set number relativenumber
set scrolloff=2
set showmatch
set tabstop=2 softtabstop=2 shiftwidth=2 expandtab
set title
set wrap breakindent
set colorcolumn=80,100
set lazyredraw
set undofile
let &undodir=fnamemodify($MYVIMRC, ":h") . "/undo"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ==> PLUGIN CONFIGURATION
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" => NERDTree
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let NERDTreeShowHidden=1
let g:NERDTreeDirArrowExpandable = '↠'
let g:NERDTreeDirArrowCollapsible = '↡'

" => Airline
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline_powerline_fonts = 1
let g:airline_section_z = ' %{strftime("%-I:%M %p")}'
let g:airline_section_warning = ''
"let g:airline#extensions#tabline#enabled = 1

" => Neovim :Terminal
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
tmap <Esc> <C-\><C-n>
tmap <C-w> <Esc><C-w>
"tmap <C-d> <Esc>:q<CR>
autocmd BufWinEnter,WinEnter term://* startinsert
autocmd BufLeave term://* stopinsert

" ==> Deoplete
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:deoplete#enable_at_startup = 1
" Disable documentation window
set completeopt-=preview

" ==> Supertab
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:SuperTabDefaultCompletionType = "<C-n>"

" Ultisnips
let g:UltiSnipsExpandTrigger="<C-Space>"
let g:UltiSnipsJumpForwardTrigger="<Tab>"
let g:UltiSnipsJumpBackwardTrigger="<C-x>"

" ==> EasyAlign
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)


" ==> indentLine
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:indentLine_char = '▏'
let g:indentLine_color_gui = '#363949'

" ==> TagBar
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:tagbar_width = 30
let g:tagbar_iconchars = ['↠', '↡']

" ==> fzf-vim
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit' }
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'Type'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Character'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }


" ==> ALE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <silent> [W <Plug>(ale_first)
nmap <silent> [w <plug>(ale_previous)
nmap <silent> ]w <plug>(ale_next)
nmap <silent> ]W <Plug>(ale_last)

" ==> vim-grepper
let g:grepper = {}
let g:grepper.tools = ['rg', 'grep', 'git']

nmap <leader>g :Grepper<CR>
nmap <Leader>G :Grepper -cword -noprompt<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ==> Filetype-Specific Configurations
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" HTML, XML, Jinja
autocmd FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType css setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType xml setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType htmldjango setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType htmldjango inoremap {{ {{  }}<left><left><left>
autocmd FileType htmldjango inoremap {% {%  %}<left><left><left>
autocmd FileType htmldjango inoremap {# {#  #}<left><left><left>

" Markdown and Journal
autocmd FileType markdown setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType journal setlocal shiftwidth=2 tabstop=2 softtabstop=2

""" Custom Functions

" Trim Whitespaces
function! TrimWhitespace()
    let l:save = winsaveview()
    %s/\\\@<!\s\+$//e
    call winrestview(l:save)
endfunction


function! ToggleBackground()
  if (&background == 'light')
    set background=dark
    echo "background -> dark"
  else
    set background=light
    echo "background -> light"
  endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ==> Custom Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Leader Mappings

let mapleader=","
nmap <leader>q :NERDTreeToggle<CR>
nmap \ <leader>q
nmap <leader>w :TagbarToggle<CR>
nmap <leader>ee :Colors<CR>
nmap <leader>ea :AirlineTheme
nmap <leader>e1 :call ColorDracula()<CR>
nmap <leader>e2 :call ColorSeoul256()<CR>
nmap <leader>e3 :call ColorForgotten()<CR>
nmap <leader>e4 :call ColorZazen()<CR>
nmap <leader>r :so ~/.config/nvim/init.vim<CR>
nmap <leader>t :call TrimWhitespace()<CR>
xmap <leader>a gaip*
nmap <leader>a gaip*
nmap <leader>s <C-w>s<C-w>j:terminal<CR>
nmap <leader>vs <C-w>v<C-w>l:terminal<CR>
nmap <leader>d <Plug>(pydocstring)
nmap <leader>f :Files<CR>
nmap <leader>g :Goyo<CR>
nmap <leader>h :RainbowParentheses!!<CR>
nmap <leader>j :set filetype=journal<CR>
nmap <leader>k :ColorToggle<CR>
nmap <leader>l :Limelight!!<CR>
xmap <leader>l :Limelight!!<CR>
autocmd FileType python nmap <leader>x :0,$!~/.config/nvim/env/bin/python -m yapf<CR>
"nmap <leader>n :HackerNews best<CR>J
nmap <silent> <leader><leader> :noh<CR>
nmap <Tab> :bnext<CR>
nmap <S-Tab> :bprevious<CR>
