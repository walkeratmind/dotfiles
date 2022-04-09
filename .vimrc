
" ------------------------------------------------------------
" Vim-Plug stuffs, see: https://github.com/junegunn/vim-plug
" ------------------------------------------------------------

" Set paths for plug.vim and directory for plugins
if has('nvim')
  let vim_plug_location=$HOME."/nvim/autoload/plug.vim"
  let vim_plug_plugins_dir = $HOME."/nvim/plugins"
else
  let vim_plug_location=$HOME.'/.vim/autoload/plug.vim'
  let vim_plug_plugins_dir = $HOME."/vim/plugins"
endif

" If vim-plug not present, install it now
if !filereadable(expand(vim_plug_location))
  echom "Vim Plug not found, downloading to '" . vim_plug_location . "'"
  execute '!curl -o ' . vim_plug_location . ' --create-dirs' .
  \ ' https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
endif

" If Plugins directory not yet exist, create it
if empty(vim_plug_plugins_dir)
  call mkdir(vim_plug_plugins_dir, 'p')
endif

" Initialize Vim Plugged
call plug#begin(vim_plug_plugins_dir)
  " Light-weight status line
  Plug 'vim-airline/vim-airline'
  " A tree explorer plugin for vim
  Plug 'preservim/nerdtree'
  " Highlight, navigate, and operate on sets of matching text
  Plug 'andymass/vim-matchup'
  " Displays and browse tags in a file
  Plug 'preservim/tagbar'
  " Fuzzy-file finder in vim
  Plug 'junegunn/fzf'
  " Smoothe scrolling
  Plug 'psliwka/vim-smoothie'
  " File icons for most languages
  Plug 'ryanoasis/vim-devicons'
  " Easy comments in most languages
  Plug 'preservim/nerdcommenter'
  " Check syntax in real-time
  Plug 'dense-analysis/ale'
  " Surround selected text with brackets, quotes, tags etc
  Plug 'tpope/vim-surround'
  " Better incremenal searching
  Plug 'haya14busa/incsearch.vim'
  " Multi-cursor support
  Plug 'mg979/vim-visual-multi'
  " Easily generate number/ letter sequences
  Plug 'triglav/vim-visual-increment'
  " Wraper for running tests
  Plug 'janko/vim-test'
call plug#end()

" ------------------------------------------------------------
" Basic Configuration Stuffs
" ------------------------------------------------------------

set encoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8

set number
set scrolloff=12 " set scroll offset at the end of line
set relativenumber "" sets relative number of line

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smartindent

filetype plugin on

" ------------------------------------------------------------
" Appreance / Theme
" ------------------------------------------------------------

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if (&t_Co > 2 || has("gui_running")) && !exists("syntax_on")
  syntax on
endif

if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

" Load matchit.vim, but only if the user hasn't installed a newer version.
if !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
  runtime! macros/matchit.vim
endif

filetype plugin indent on

augroup vimrcEx
  autocmd!

  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
    \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

  " Set syntax highlighting for specific file types
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd BufRead,BufNewFile .{jscs,jshint,eslint}rc set filetype=json
  autocmd BufRead,BufNewFile
    \ aliases.local,
    \zshenv.local,zlogin.local,zlogout.local,zshrc.local,zprofile.local,
    \*/zsh/configs/*
    \ set filetype=sh
  autocmd BufRead,BufNewFile gitconfig.local set filetype=gitconfig
  autocmd BufRead,BufNewFile tmux.conf.local set filetype=tmux
  autocmd BufRead,BufNewFile vimrc.local set filetype=vim
augroup END

" When the type of shell script is /bin/sh, assume a POSIX-compatible
" shell for syntax highlighting purposes.
let g:is_posix = 1

" Display extra whitespace
set list listchars=tab:»·,trail:·,nbsp:·

" Use one space, not two, after punctuation.
set nojoinspaces

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in fzf for listing files. Lightning fast and respects .gitignore
  let $FZF_DEFAULT_COMMAND = 'ag --literal --files-with-matches --nocolor --hidden -g ""'

  if !exists(":Ag")
    command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
    nnoremap \ :Ag<SPACE>
  endif
endif

" Make it obvious where 80 characters is
set textwidth=80
set colorcolumn=+1

" Numbers
set number
set numberwidth=5

" Treat <li> and <p> tags like the block tags they are
let g:html_indent_tags = 'li\|p'

" Set tags for vim-fugitive
set tags^=.git/tags

" Open new split panes to right and bottom, which feels more natural
set splitbelow
set splitright

" Set spellfile to location that is guaranteed to exist, can be symlinked to
" Dropbox or kept in Git and managed outside of thoughtbot/dotfiles using rcm.
set spellfile=$HOME/.vim-spell-en.utf-8.add

" Autocomplete with dictionary words when spell check is on
set complete+=kspell

" Always use vertical diffs
set diffopt+=vertical

" Local config
if filereadable($HOME . "/.vimrc.local")
  source ~/.vimrc.local
endif

" ------------------------------------------------------------
" Key Mappings
" ------------------------------------------------------------

" Leader
let mapleader = " " "  add space as the leader key here


" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<Tab>"
    else
        return "\<C-p>"
    endif
endfunction
inoremap <Tab> <C-r>=InsertTabWrapper()<CR>
inoremap <S-Tab> <C-n>

" Switch between the last two files
nnoremap <Leader><Leader> <C-^>

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" vim-test mappings
nnoremap <silent> <Leader>t :TestFile<CR>
nnoremap <silent> <Leader>s :TestNearest<CR>
nnoremap <silent> <Leader>l :TestLast<CR>
nnoremap <silent> <Leader>a :TestSuite<CR>
nnoremap <silent> <Leader>gt :TestVisit<CR>

" Run commands that require an interactive shell
nnoremap <Leader>r :RunInInteractiveShell<Space>

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Move between linting errors
nnoremap ]r :ALENextWrap<CR>
nnoremap [r :ALEPreviousWrap<CR>

" Map Ctrl + p to open fuzzy find (FZF)
nnoremap <c-p> :Files<cr>




set visualbell
set noerrorbells
