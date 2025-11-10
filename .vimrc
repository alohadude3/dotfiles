"to use ~/.vimrc in neovim add `source ~/.vimrc` to:
"Windows ~/AppData/Local/nvim/init.vim
"MacOS/Linux ~/.config.nvim/init.vim

" Show line number
set number

" Show relative line number
set relativenumber

" Turn on the Wild menu
set wildmenu

" Show matching brackets when text indicator is over them
set showmatch

" Always show current position
set ruler

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Add a bit extra margin to the left
set foldcolumn=1

" Enable syntax highlighting
syntax enable

set background=dark

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
" set lbr
" set tw=500

set ai "Auto indent
set si "Smart indent

" Always show the status line
set laststatus=2

