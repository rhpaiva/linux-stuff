colorscheme slate
syntax on  "Enables syntax highlighting for programming languages

set mouse=a  "Allows you to click around the text editor with your mouse to move the cursor
set backspace=2  "This makes the backspace key function like it does in other programs.
"colorscheme darkblue  "Changes the color scheme. Change this to your liking. Lookin /usr/share/vim/vim61/colors/ for options.
"setlocal spell  "Enables spell checking (CURRENTLY DISABLED because it's kinda annoying). Make sure to uncomment the next line if you use this.
"set spellfile=~/.vimwords.add  "The location of the spellcheck dictionary. Uncomment this line if you uncomment the previous line.
set foldmethod=manual  "Lets you hide sections of code

"--- The following commands make the navigation keys work like standard editors
imap <silent> <Down> <C-o>gj
imap <silent> <Up> <C-o>gk
nmap <silent> <Down> gj
nmap <silent> <Up> gk
"--- Ends navigation commands

"--- The following adds a sweet menu, press F4 to use it.
source $VIMRUNTIME/menu.vim
set wildmenu
set cpo-=<
set wcm=<C-Z>
map <F4> :emenu <C-Z>
"--- End sweet menua


"## General
set number	" Show line numbers
set linebreak	" Break lines at word (requires Wrap lines)
set showbreak=+++	" Wrap-broken line prefix
set textwidth=100	" Line wrap (number of cols)
set showmatch	" Highlight matching brace
set visualbell	" Use visual bell (no beeping)
 
set hlsearch	" Highlight all search results
set smartcase	" Enable smart-case search
set gdefault	" Always substitute all matches in a line
set ignorecase	" Always case-insensitive
set incsearch	" Searches for strings incrementally
  
set autoindent	" Auto-indent new lines
set expandtab	" Use spaces instead of tabs
set shiftwidth=4	" Number of auto-indent spaces
"set smartindent	" Enable smart-indent
set smarttab	" Enable smart-tabs
set softtabstop=4	" Number of spaces per Tab
   
"## Advanced
set ruler	" Show row and column ruler information
    
set undolevels=1000	" Number of undo levels
set backspace=indent,eol,start	" Backspace behaviour
set nocompatible "This fixes the problem where arrow keys do not function properly on some systems.

