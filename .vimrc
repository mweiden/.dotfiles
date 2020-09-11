set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

Bundle 'Lokaltog/powerline'
Bundle 'altercation/vim-colors-solarized'
Bundle 'Lokaltog/powerline-fonts'
Bundle 'vim-ruby/vim-ruby'
Bundle 'JuliaLang/julia-vim'
Bundle 'derekwyatt/vim-scala'
Bundle 'airblade/vim-gitgutter'
Bundle 'mileszs/ack.vim'
Bundle 'tpope/vim-surround.git'
Bundle 'jnwhiteh/vim-golang'
Bundle 'uarun/vim-protobuf'

call plug#begin('~/.vim/plugged')
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
call plug#end()
" Bundle 'andreypopp/ensime'
" Bundle 'jlc/envim'
" Bundle 'jlc/ensime-common'
" Bundle 'jlc/vim-async-beans'
" Bundle 'jlc/vim-addon-async'
" Bundle 'MarcWeber/vim-addon-signs'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" TMUX conf
if $TMUX == ''
  set clipboard+=unnamed
endif


" A couple options to make powerline work correctly.
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
set laststatus=2

"let g:Powerline_symbols = 'compatible'

" Ensime Config

autocmd FileType scala nnoremap <F5> :EnsimeTypecheckFile<CR>
autocmd FileType scala nnoremap <leader>, :EnsimeTypeAtPoint<CR>

" basics

let mapleader = " "

set encoding=utf-8
set history=1000
set nocompatible            " don't need vi compatibility
set noerrorbells            " stop the stupid sound
set novisualbell            " stop the stupid flash
set backspace=indent,eol,start

" search and navigation

set ignorecase              " makes / searches case insensitive
set wildmenu                " bash-like cycling
set wildmode=list:longest
set incsearch

" pasting sanity

  " Fix this!

" file search
set wildignore+=*.lock,*.original,*.properties,*.o,*.obj,.git,tags,*.class,*.gem,*.xsd,*.dtd,**/ivy2/**,**/target/**,*.jar,**/bundle/**,**/protoc/**,**/*hadoop*/**,**/hadoop-data/**,*.pyc,**/assembly/**,**/tmp/**,**/target/**,*.class,*.pyo,*.pyc

" safety

set undofile
set noswapfile
set nobackup                " no backup after closing
set nowritebackup           " no backup while working
set undodir=/tmp/.vim_undo

" ui

set title                   " show title of file in menu bar
set ruler
set relativenumber
set number                  " numbers on the left
"au BufReadPost * set relativenumber
set scrolloff=1             " breathing room for zt
set laststatus=2
set mouse=a
map <ScrollWheelUp> <C-y>
map <ScrollWheelDown> <C-e>
" set term=screen-256color

" folds

set foldmethod=indent
set foldlevel=1
set foldnestmax=10
set nofoldenable

highlight Folded ctermfg=grey
highlight Folded ctermbg=NONE

map <Leader>f za<CR>

" column width

set textwidth=78
set colorcolumn=+1

" stripping

map <Leader>w :%s/\v\s+$//g<CR>
set list listchars=tab:..,trail:.

" indentation

set wrap
set expandtab
set formatoptions=qrn1
set autoindent              " always set autoindenting on
set shiftwidth=2            " number of spaces to use for autoindenting
set softtabstop=2
set tabstop=2
set expandtab

" global remappings

map <leader>a :Ack
"map <leader>b :b
map <leader>d :bd<CR>
map <leader>o :o .<CR>
map <leader>p :Files .<CR>
map <leader>q :q<CR>
"map <leader>s :w<CR>
map <leader>vv :source ~/.vimrc<CR>
map <leader>e  :Sex<CR>

nmap <c-j> o<Esc>
nmap <c-k> O<Esc>

" interactive mode

"imap <c-k> <esc>

" visual mode

vmap > >gv
vmap < <gv

" cycle through buffers

map <c-n> :bnext<cr>
map <c-p> :bprevious<cr>

" fix regular expressions

nmap / /\v
vmap / /\v

" copy current filename to clipboard

nmap <C-o> :!echo % \| pbcopy<cr><cr>

" stop that.

noremap  <Up> ""
noremap  <Down> ""
noremap  <Left> ""
noremap  <Right> ""

" reload testing screen

map <leader>t :!ssh dev "screen -x tests -p test -X stuff 'R'"<CR><CR>
map <leader>u :!tmux send-keys -t 1 R<CR><CR>

" persist marks, registers history and buffer list across restarts

set viminfo='10,\"100,:20,%,n~/.viminfo

" restore cursor to saved position

au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

" generate ctags on save

au BufWritePost *.scala,*.jl,*.rb,*.c,*.h,*.cpp,*.py silent! !ctags -a <afile> 2> /dev/null &

" solarized

syntax enable

set guifont=Menlo\ Regular\ for\ Powerline
"let g:Powerline_theme="cmdwin"
let g:Powerline_symbols='fancy'

if $VIM_THEME == "light"
  set background=light
  let g:Powerline_colorscheme="default"
else
  set background=dark
  let g:Powerline_colorscheme="Solarized Dark"
endif
set t_Co=256
colorscheme solarized

" Vim gutter
let g:gitgutter_enabled = 1
"let g:gitgutter_highlight_lines = 0
"highlight clear SignColumn
"au BufReadPost * highlight SignColumn ctermbg=NONE
"au BufWritePost * highlight SignColumn ctermbg=NONE
highlight SignColumn ctermbg=NONE
hi CursorLineNr guifg=#00ff00

" Custom Changes

set hlsearch

set backupdir-=~/Documents/autosave
set backupdir^=/tmp


augroup filetypedetect
  au BufNewFile,BufRead *.pig set filetype=pig syntax=pig
augroup END

augroup filetypedetect
  au BufNewFile,BufRead *.jl set filetype=julia syntax=julia
augroup END
