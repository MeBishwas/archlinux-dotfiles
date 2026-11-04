" =============================================================================
"  ~/.vimrc  --  a complete, heavily commented Vim configuration
" =============================================================================
"  INSTALL
"    1. Save this file as ~/.vimrc   (Windows: ~/_vimrc)
"    2. Install vim-plug (the plugin manager):
"         curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"    3. Open Vim and run  :PlugInstall
"    4. Optional but recommended: install Node.js (for coc.nvim), ripgrep (rg)
"       and fzf on your system.
"
"  CONCEPTS YOU WILL SEE EXPLAINED INLINE
"    modes, options (:set), mappings (map/noremap), leader key, autocommands,
"    registers, buffers/windows/tabs, folds, marks, text objects, plugins.
"
"  Lines starting with a double quote (") are comments.
" =============================================================================


" -----------------------------------------------------------------------------
" 0. BOOTSTRAP
" -----------------------------------------------------------------------------
" Vim vs Vi: 'nocompatible' turns on all the modern Vim features. Vim sets this
" automatically when it finds a vimrc, but being explicit is harmless.
set nocompatible


" Auto-install vim-plug if it is missing (first run on a fresh machine).
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" -----------------------------------------------------------------------------
" 1. LEADER KEYS
" -----------------------------------------------------------------------------
" CONCEPT: <leader> is a user-defined prefix key so you can create your own
" shortcut namespace (<leader>w, <leader>f ...) without clobbering built-ins.
" <localleader> is the same idea but intended for filetype-specific mappings.
" Must be set BEFORE any mapping that uses <leader>.
let mapleader      = " "     " Space is the most popular leader
let maplocalleader = ","


" -----------------------------------------------------------------------------
" 2. PLUGINS  (vim-plug)
" -----------------------------------------------------------------------------
" CONCEPT: Vim 8+ has native packages (:help packages), but a manager such as
" vim-plug adds parallel install, lazy loading and one-line declarations.
" Commands:  :PlugInstall  :PlugUpdate  :PlugClean  :PlugStatus  :PlugUpgrade
call plug#begin('~/.vim/plugged')



" ---- Appearance ----
Plug 'morhetz/gruvbox'                  " Popular, easy-on-the-eyes colorscheme
Plug 'vim-airline/vim-airline'          " Informative status/tab line
Plug 'vim-airline/vim-airline-themes'
Plug 'ryanoasis/vim-devicons'           " File icons (needs a Nerd Font)
Plug 'Yggdroot/indentLine'              " Visual indent guides
Plug 'luochen1990/rainbow'              " Rainbow-colored matching brackets

" ---- Navigation / search ----
Plug 'preservim/nerdtree'               " File-tree sidebar
Plug 'Xuyuanp/nerdtree-git-plugin'      " Git status flags in NERDTree
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'                 " Fuzzy finder: files, buffers, grep...
Plug 'easymotion/vim-easymotion'        " Jump anywhere on screen in 2-3 keys
Plug 'christoomey/vim-tmux-navigator'   " Seamless Ctrl-hjkl between Vim/tmux
Plug 'mbbill/undotree'                  " Visualise the undo *tree*
Plug 'liuchengxu/vim-which-key'         " Popup that lists your leader mappings

" ---- Editing ----
Plug 'tpope/vim-surround'               " cs"'  ds(  ysiw]  (change surroundings)
Plug 'tpope/vim-commentary'             " gcc / gc{motion} toggles comments
Plug 'tpope/vim-repeat'                 " Makes '.' work with plugin mappings
Plug 'tpope/vim-unimpaired'             " [b ]b  [q ]q  [<Space> ]<Space> ...
Plug 'tpope/vim-sleuth'                 " Auto-detect indentation per file
Plug 'tpope/vim-eunuch'                 " :Rename :Delete :Mkdir :SudoWrite
Plug 'jiangmiao/auto-pairs'             " Auto-close brackets and quotes
Plug 'junegunn/vim-easy-align'          " ga= to align on '=' etc.
Plug 'wellle/targets.vim'               " More text objects (in-arg, next-paren)
Plug 'michaeljsmith/vim-indent-object'  " ai / ii indent-level text objects
Plug 'mg979/vim-visual-multi'           " Multiple cursors (Ctrl-n)

" ---- Git ----
Plug 'tpope/vim-fugitive'               " :Git, :Gdiffsplit, :Gblame ...
Plug 'airblade/vim-gitgutter'           " Added/changed/removed marks in gutter
Plug 'junegunn/gv.vim'                  " :GV commit browser

" ---- Language support / IDE-like features ----
Plug 'sheerun/vim-polyglot'             " Syntax + indent for ~200 languages
Plug 'neoclide/coc.nvim', {'branch': 'release'}   " LSP client + completion
Plug 'SirVer/ultisnips'                 " Snippet engine
Plug 'honza/vim-snippets'               " Ready-made snippets
Plug 'dense-analysis/ale'               " Async linting / fixing (diagnostics
                                        " from ALE are routed to coc below
                                        " to avoid duplicates)
Plug 'preservim/tagbar'                 " Outline of symbols (needs ctags)

" ---- Writing / misc ----
Plug 'preservim/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown'] }
Plug 'junegunn/goyo.vim'                " Distraction-free writing  :Goyo
Plug 'mhinz/vim-startify'               " Fancy start screen with recent files

call plug#end()
" plug#end() also runs 'filetype plugin indent on' and 'syntax enable'.


" -----------------------------------------------------------------------------
" 3. CORE OPTIONS  (:set)
" -----------------------------------------------------------------------------
" CONCEPT: Options are named settings. Boolean: 'set number' / 'set nonumber' /
" 'set number!' (toggle) / 'set number?' (query). Value: 'set tabstop=4'.
" Use :help 'optionname' to read the docs for any of them.

" ---- Files & encoding ----
set encoding=utf-8
set fileencoding=utf-8
set hidden                  " Allow switching buffers with unsaved changes
set autoread                " Reload files changed outside Vim
set confirm                 " Ask to save instead of failing on :q
set nobackup                " Some LSP servers choke on backup files
set nowritebackup
set noswapfile              " Disable .swp files (use persistent undo instead)

" ---- Undo that survives restarts ----
" CONCEPT: Vim's undo is a TREE, not a line. Undo, then edit => a new branch.
" :undolist shows branches; :earlier 10m / :later 5m travel in time;
" the undotree plugin visualises it.
if has('persistent_undo')
  let s:undo_dir = expand('~/.vim/undo')
  if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p', 0700)
  endif
  let &undodir = s:undo_dir
  set undofile
  set undolevels=10000
endif

" ---- UI ----
set number                  " Absolute line number on the current line...
set relativenumber          " ...relative numbers elsewhere (makes 5j, 12k easy)
set cursorline              " Highlight current line
set signcolumn=yes          " Always show the gutter (avoids layout jumps)
set showcmd                 " Show partial command in the bottom-right
set showmode                " Show -- INSERT -- etc. (airline also shows it)
set ruler
set laststatus=2            " Always show a status line
set wildmenu                " Enhanced command-line completion
set wildmode=longest:full,full
set wildoptions=pum         " Popup-style completion menu for : commands
set scrolloff=8             " Keep 8 lines of context above/below the cursor
set sidescrolloff=8
set display+=lastline
set shortmess+=c            " Quieter completion messages
set cmdheight=1
set updatetime=300          " Faster CursorHold events (git-gutter, coc)
set timeoutlen=500          " Time allowed for a mapped key sequence
set ttimeoutlen=10          " Instant <Esc> in terminal Vim
set lazyredraw              " Don't redraw during macros
set ttyfast
set mouse=a                 " Mouse in all modes (handy for resizing splits)
set termguicolors           " 24-bit colour (needs a modern terminal)
set background=dark
set colorcolumn=80,120      " Soft guides for line length
set list                    " Show invisible characters...
set listchars=tab:»·,trail:·,nbsp:␣,extends:›,precedes:‹
set splitbelow              " New horizontal splits go below
set splitright              " New vertical splits go right
set noerrorbells visualbell t_vb=
set title

" ---- Text wrapping ----
set nowrap                  " Don't wrap long lines (toggle with <leader>tw)
set linebreak               " When wrapping, break at word boundaries
set breakindent             " Wrapped lines keep their indent
set showbreak=↪\

" ---- Indentation ----
" CONCEPT: tabstop = how wide a <Tab> *looks*.  shiftwidth = how far >> and
" auto-indent move. softtabstop = how far <Tab>/<BS> feel in insert mode.
" expandtab = insert spaces instead of real tab characters.
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab
set autoindent
set smartindent
set shiftround              " Round indent to a multiple of shiftwidth

" ---- Searching ----
" CONCEPT: / searches forward, ? backward, n/N repeat, * / # search the word
" under the cursor. Search is regex-based: \v enables "very magic" (sane regex).
set incsearch               " Show matches while typing
set hlsearch                " Highlight all matches
set ignorecase              " Case-insensitive...
set smartcase               " ...unless the pattern contains a capital
set wrapscan
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
  set grepformat=%f:%l:%c:%m
endif

" ---- Editing behaviour ----
set backspace=indent,eol,start   " Make <BS> behave like in other editors
set whichwrap+=<,>,h,l           " Allow cursor to wrap across lines
set virtualedit=block            " Visual-block can go past end of line
set formatoptions-=cro           " Don't auto-continue comments with o/O/Enter
set nrformats-=octal             " Ctrl-a on 007 should give 008, not 010
set matchpairs+=<:>              " % jumps between < and > too
if exists('+splitkeep') | set splitkeep=screen | endif
set completeopt=menuone,noinsert,noselect
set pumheight=12
set history=1000
set viminfo='100,<50,s10,h       " Remember marks, registers, history


" ============================================================================
" SYSTEM CLIPBOARD
" ============================================================================

" Use the system clipboard for Vim yank, delete, and paste operations.
set clipboard=unnamedplus

" ============================================================================
" CLIPBOARD SHORTCUTS
" "
" ============================================================================
"
" " Copy the current line to the system clipboard
  nnoremap <leader>y "+yy
"
" " Copy the selected text in Visual mode
 vnoremap <leader>y "+y
"
" " Copy the entire file to the system clipboard
nnoremap <leader>Y :%y+<CR>
"
" " Paste from the system clipboard
 nnoremap <leader>p "+p
 nnoremap <leader>P "+P
"
" " Copy the current file path to the system clipboard
 nnoremap <leader>yp :let @+ = expand('%:p')<CR>:echo "File path copied"<CR>]
























" ---- Folding ----
" CONCEPT: Folds collapse regions of text. zo/zc open/close, za toggle,
" zR open all, zM close all, zj/zk move between folds.
set foldmethod=indent       " Fold by indentation (other options: syntax, marker,
set foldlevelstart=99       " expr). 99 => start with everything open.
set foldnestmax=4

" ---- Spell check (off by default; toggle with <leader>ts) ----
set spelllang=en_us
set spellfile=~/.vim/spell/en.utf-8.add
" ]s / [s next/prev misspelling, z= suggestions, zg add word, zw mark wrong


" -----------------------------------------------------------------------------
" 4. COLOURS AND THEME
" -----------------------------------------------------------------------------
syntax enable
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_italic = 1
silent! colorscheme gruvbox" 'silent!' so a missing theme won't error
"colorscheme habamax " Nice

" -----------------------------------------------------------------------------
" 5. KEY MAPPINGS
" -----------------------------------------------------------------------------
" CONCEPT: Modes -- Normal (commands), Insert (typing), Visual (selecting),
" Command-line (:), Terminal. Mapping prefixes:
"     nmap / imap / vmap / cmap / tmap  -> recursive mappings per mode
"     nnoremap / inoremap / vnoremap ... -> NON-recursive (always prefer these)
"     <silent>  don't echo the command    <expr> mapping evaluates an expression
"     <buffer>  mapping local to a buffer <CR> Enter  <Esc> Escape  <C-x> Ctrl+x

" ---- Sanity ----
nnoremap Y y$
nnoremap <silent> <Esc><Esc> :nohlsearch<CR>
nnoremap n nzzzv
nnoremap N Nzzzv
nnoremap J mzJ`z
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
inoremap jk <Esc>
inoremap kj <Esc>

" ---- Moving over wrapped lines as if they were separate lines ----
nnoremap <expr> j v:count == 0 ? 'gj' : 'j'
nnoremap <expr> k v:count == 0 ? 'gk' : 'k'

" ---- Faster save / quit ----
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :qa!<CR>
nnoremap <leader>x :x<CR>
" Save a root-owned file you forgot to open with sudo
cnoremap w!! w !sudo tee % >/dev/null

" ---- Editing the config itself ----
nnoremap <leader>ev :edit $MYVIMRC<CR>
nnoremap <leader>sr :source $MYVIMRC<CR>:echo "vimrc reloaded"<CR>

" ---- Windows ----
" CONCEPT: A *buffer* is a file in memory. A *window* is a viewport onto a
" buffer. A *tab page* is a layout of windows. (Tabs are NOT files!)
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <leader>sh :split<CR>
nnoremap <leader>sv :vsplit<CR>
nnoremap <leader>= <C-w>=
nnoremap <leader>z :tab split<CR>
nnoremap <C-Up>    :resize +2<CR>
nnoremap <C-Down>  :resize -2<CR>
nnoremap <C-Left>  :vertical resize -2<CR>
nnoremap <C-Right> :vertical resize +2<CR>

" ---- Buffers ----
nnoremap <Tab>   :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
nnoremap <leader>bd :bdelete<CR>
nnoremap <leader>bo :%bd\|e#\|bd#<CR>
nnoremap <leader><leader> <C-^>

" ---- Tabs ----
nnoremap <leader>tn :tabnew<CR>
nnoremap <leader>tc :tabclose<CR>
nnoremap ]t :tabnext<CR>
nnoremap [t :tabprevious<CR>

" ---- Moving lines / blocks ----
" Alt-j / Alt-k move the line (or visual selection) down/up.
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" ---- Stay in visual mode when indenting ----
vnoremap < <gv
vnoremap > >gv

" ---- Registers ----
" CONCEPT: Registers are named clipboards.  "ayy yanks into register a,
" "ap pastes it. "0 = last yank, "" = unnamed, "+ = system clipboard,
" "_ = black hole (discards), ". = last inserted text, ": = last command.
" :registers (or :reg) lists them. Uppercase ("Ayy) APPENDS.
" Paste over a selection without losing what you yanked:
xnoremap <leader>p "_dP
" Delete without yanking:
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" ---- Marks ----
" CONCEPT: ma sets mark a in this file; 'a jumps to its line, `a to its exact
" position. Uppercase marks (mA) are GLOBAL across files. '' jumps back.
" '. = last change, '^ = last insert, '[ '] = last yanked/changed region.
" :marks lists them.

" ---- Search and replace ----
" CONCEPT: :%s/old/new/gc   % = whole file, g = all matches per line,
" c = confirm each. & repeats the last :s on the current line, g& on all.
nnoremap <leader>r :%s/\<<C-r><C-w>\>//gc<Left><Left><Left>
vnoremap <leader>r y:%s/<C-r>"//gc<Left><Left><Left>
" * in visual mode searches for the selection
vnoremap * y/\V<C-r>=escape(@",'/\')<CR><CR>

" ---- Quickfix / location list ----
" CONCEPT: Lists of file:line locations produced by :grep, :make, linters, LSP.
nnoremap <leader>co :copen<CR>
nnoremap <leader>cc :cclose<CR>
nnoremap ]q :cnext<CR>
nnoremap [q :cprevious<CR>
nnoremap <leader>ll :lopen<CR>

" ---- Toggles ----
nnoremap <leader>tw :set wrap!<CR>
nnoremap <leader>tr :set number! relativenumber!<CR>
nnoremap <leader>ts :setlocal spell!<CR>
nnoremap <leader>tl :set list!<CR>
nnoremap <leader>th :set hlsearch!<CR>

" ---- Terminal ----
" CONCEPT: Vim 8.1+ has a built-in terminal. :terminal opens one; Ctrl-\ Ctrl-n
" returns to Normal mode inside it.
nnoremap <leader>T :belowright terminal ++rows=12<CR>
tnoremap <Esc><Esc> <C-\><C-n>
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l

" ---- Command-line editing (emacs-style) ----
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" ---- Insert-mode conveniences ----
inoremap <C-s> <Esc>:w<CR>a
inoremap <C-l> <C-o>A

" ---- Run the current file (simple "make-it-go") ----
augroup run_file
  autocmd!
  autocmd FileType python     nnoremap <buffer> <F5> :w<CR>:!python3 %<CR>
  autocmd FileType sh         nnoremap <buffer> <F5> :w<CR>:!bash %<CR>
  autocmd FileType javascript nnoremap <buffer> <F5> :w<CR>:!node %<CR>
  autocmd FileType go         nnoremap <buffer> <F5> :w<CR>:!go run %<CR>
  autocmd FileType rust       nnoremap <buffer> <F5> :w<CR>:!cargo run<CR>
  autocmd FileType c          nnoremap <buffer> <F5> :w<CR>:!gcc % -o %:r && ./%:r<CR>
augroup END


" -----------------------------------------------------------------------------
" 6. AUTOCOMMANDS
" -----------------------------------------------------------------------------
" CONCEPT: An autocommand runs a command when an event fires (BufRead,
" BufWritePre, FileType, VimEnter, CursorHold, ...). ALWAYS wrap them in an
" augroup with 'autocmd!' first, otherwise re-sourcing the vimrc duplicates them.

augroup general
  autocmd!
  " Jump to the last cursor position when reopening a file
  autocmd BufReadPost *
    \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g`\""
    \ | endif

  " Strip trailing whitespace on save (except in Markdown, where it is syntax)
  autocmd BufWritePre * if &ft !=# 'markdown' | %s/\s\+$//e | endif

  " Reload files changed on disk when Vim regains focus
  autocmd FocusGained,BufEnter,CursorHold * if mode() !=# 'c' | checktime | endif

  " Equalise splits when the terminal is resized
  autocmd VimResized * wincmd =

  " Only show the cursorline in the active window
  autocmd WinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline

  " Highlight yanked text briefly (Vim 9+ has no built-in; keep as a hint)
  " Use a plugin such as 'machakann/vim-highlightedyank' if you want it.
augroup END

" ---- Per-filetype settings ----
" CONCEPT: 'setlocal' applies only to the current buffer, which is exactly what
" you want inside a FileType autocmd.
augroup filetypes
  autocmd!
  autocmd FileType python       setlocal ts=4 sw=4 sts=4 et colorcolumn=88
  autocmd FileType javascript,typescript,json,yaml,html,css,vue,svelte
        \ setlocal ts=2 sw=2 sts=2 et
  autocmd FileType go           setlocal noexpandtab ts=4 sw=4 foldmethod=syntax
  autocmd FileType make         setlocal noexpandtab
  autocmd FileType markdown     setlocal wrap spell textwidth=80 conceallevel=2
  autocmd FileType gitcommit    setlocal spell textwidth=72
  autocmd FileType help         nnoremap <buffer> q :q<CR>
  autocmd FileType qf           nnoremap <buffer> q :q<CR>
  autocmd BufNewFile,BufRead *.conf,*.cfg setfiletype dosini
  autocmd BufNewFile,BufRead Dockerfile*  setfiletype dockerfile
augroup END


" -----------------------------------------------------------------------------
" 7. PLUGIN CONFIGURATION
" -----------------------------------------------------------------------------

" ---- vim-airline ----
let g:airline_theme = 'gruvbox'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1          " Show buffers on top
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#hunks#enabled = 1

" ---- NERDTree ----
" CONCEPT (netrw): Vim ships with a built-in file browser called netrw
" (:Explore, :Vexplore). NERDTree is a richer alternative.
let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = ['\.git$', '\.pyc$', '__pycache__', 'node_modules', '\.DS_Store']
let g:NERDTreeWinSize = 32
nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>E :NERDTreeFind<CR>
" Close Vim if NERDTree is the only window left
autocmd BufEnter * if winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" ---- fzf.vim ----
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.8 } }
let g:fzf_preview_window = ['right:50%', 'ctrl-/']
nnoremap <C-p>      :Files<CR>
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fr :Rg<CR>
nnoremap <leader>fl :BLines<CR>
nnoremap <leader>fh :History<CR>
nnoremap <leader>fc :Commands<CR>
nnoremap <leader>fm :Marks<CR>
nnoremap <leader>fk :Maps<CR>
nnoremap <leader>fw :Rg <C-r><C-w><CR>

" ---- EasyMotion ----
let g:EasyMotion_smartcase = 1
map  s <Plug>(easymotion-bd-f2)
nmap s <Plug>(easymotion-overwin-f2)
map  <leader>j <Plug>(easymotion-j)
map  <leader>k <Plug>(easymotion-k)

" ---- vim-easy-align ----
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" ---- undotree ----
nnoremap <leader>u :UndotreeToggle<CR>
let g:undotree_SetFocusWhenToggle = 1

" ---- gitgutter / fugitive ----
let g:gitgutter_sign_added    = '▎'
let g:gitgutter_sign_modified = '▎'
let g:gitgutter_sign_removed  = '▁'
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap <leader>hs <Plug>(GitGutterStageHunk)
nmap <leader>hu <Plug>(GitGutterUndoHunk)
nmap <leader>hp <Plug>(GitGutterPreviewHunk)
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gl :GV<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gb :Git blame<CR>

" ---- Tagbar ----
nnoremap <leader>o :TagbarToggle<CR>

" ---- indentLine / rainbow ----
let g:indentLine_char = '│'
let g:indentLine_fileTypeExclude = ['help', 'startify', 'nerdtree', 'markdown', 'json']
let g:rainbow_active = 1

" ---- auto-pairs ----
let g:AutoPairsShortcutToggle = ''    " Disable its default Alt-p toggle

" ---- markdown ----
let g:vim_markdown_folding_disabled = 1
let g:mkdp_auto_close = 0
nnoremap <leader>mp :MarkdownPreviewToggle<CR>

" ---- Goyo ----
nnoremap <leader>G :Goyo<CR>

" ---- vim-visual-multi ----
let g:VM_maps = {}
let g:VM_maps['Find Under']         = '<C-n>'
let g:VM_maps['Find Subword Under'] = '<C-n>'

" ---- UltiSnips ----
let g:UltiSnipsExpandTrigger       = '<C-j>'
let g:UltiSnipsJumpForwardTrigger  = '<C-j>'
let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

" ---- ALE (linting). coc handles LSP diagnostics, so ALE only fixes/lints
"      tools that have no language server. ----
let g:ale_disable_lsp = 1
let g:ale_fix_on_save = 1
let g:ale_fixers = {
  \ '*':          ['remove_trailing_lines', 'trim_whitespace'],
  \ 'python':     ['black', 'isort'],
  \ 'javascript': ['prettier'],
  \ 'typescript': ['prettier'],
  \ 'json':       ['prettier'],
  \ 'css':        ['prettier'],
  \ 'go':         ['gofmt'],
  \ 'rust':       ['rustfmt'],
  \ }

" ---- which-key: shows a popup of available <leader> mappings ----
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>
set timeoutlen=400


" -----------------------------------------------------------------------------
" 8. COC.NVIM  (language server protocol: completion, go-to-def, rename...)
" -----------------------------------------------------------------------------
" Needs Node.js >= 16. Language servers are installed as coc "extensions".
let g:coc_global_extensions = [
  \ 'coc-json', 'coc-tsserver', 'coc-pyright', 'coc-html', 'coc-css',
  \ 'coc-yaml', 'coc-sh', 'coc-clangd', 'coc-go', 'coc-rust-analyzer',
  \ 'coc-snippets', 'coc-pairs', 'coc-prettier', 'coc-eslint', 'coc-lists',
  \ 'coc-vimlsp', 'coc-markdownlint'
  \ ]

" Tab / Shift-Tab cycle through the completion menu; Enter confirms.
inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-Tab> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
inoremap <silent><expr> <C-Space> coc#refresh()

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Diagnostics navigation
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Hover documentation with K
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol (and its references) under the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Refactoring / actions
nmap <leader>rn <Plug>(coc-rename)
nmap <leader>ca <Plug>(coc-codeaction-cursor)
xmap <leader>ca <Plug>(coc-codeaction-selected)
nmap <leader>qf <Plug>(coc-fix-current)
xmap <leader>F  <Plug>(coc-format-selected)
nmap <leader>F  <Plug>(coc-format)
command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=0 OR     :call CocActionAsync('runCommand', 'editor.action.organizeImport')

" Text objects powered by the language server: if/af (function), ic/ac (class)
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Scroll floating windows
nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

" CoC lists
nnoremap <silent><nowait> <leader>ld :<C-u>CocList diagnostics<CR>
nnoremap <silent><nowait> <leader>le :<C-u>CocList extensions<CR>
nnoremap <silent><nowait> <leader>ls :<C-u>CocList -I symbols<CR>
nnoremap <silent><nowait> <leader>lo :<C-u>CocList outline<CR>

" Use coc status in airline
set statusline^=%{coc#status()}


" -----------------------------------------------------------------------------
" 9. CUSTOM COMMANDS AND FUNCTIONS
" -----------------------------------------------------------------------------
" CONCEPT: Vimscript functions must start with an uppercase letter (or s:/g:
" scope). User commands (:command!) must also start uppercase.

" Remove trailing whitespace on demand
command! TrimWhitespace %s/\s\+$//e | nohlsearch

" Open a scratch buffer
command! Scratch new | setlocal buftype=nofile bufhidden=hide noswapfile

" Show the highlight group under the cursor (great for theme debugging)
function! SynStack()
  if !exists('*synstack') | return | endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction
nnoremap <leader>hi :call SynStack()<CR>

" Toggle quickfix window
function! ToggleQuickfix()
  if empty(filter(getwininfo(), 'v:val.quickfix'))
    copen
  else
    cclose
  endif
endfunction
nnoremap <leader>cq :call ToggleQuickfix()<CR>

" Make a directory for a file on write if it doesn't exist
augroup mkdir_on_write
  autocmd!
  autocmd BufWritePre * call s:MkNonExDir(expand('<afile>:p:h'), +expand('<abuf>'))
augroup END
function! s:MkNonExDir(dir, buf)
  if empty(getbufvar(a:buf, '&buftype')) && a:dir !~# '\v^\w+:\/\/'
    if !isdirectory(a:dir) | call mkdir(a:dir, 'p') | endif
  endif
endfunction


" -----------------------------------------------------------------------------
" 10. STARTIFY (start screen)
" -----------------------------------------------------------------------------
let g:startify_session_dir = '~/.vim/sessions'
let g:startify_lists = [
  \ { 'type': 'sessions',  'header': ['   Sessions']       },
  \ { 'type': 'files',     'header': ['   Recent files']   },
  \ { 'type': 'dir',       'header': ['   Current dir']    },
  \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
  \ ]
let g:startify_bookmarks = [ {'v': '~/.vimrc'} ]
let g:startify_change_to_vcs_root = 1
" SESSIONS: :mksession! file.vim saves windows/tabs/buffers; vim -S file.vim
" restores. Startify wraps this as :SSave / :SLoad / :SDelete.


" -----------------------------------------------------------------------------
" 11. LOCAL OVERRIDES
" -----------------------------------------------------------------------------
" Machine-specific settings go in ~/.vimrc.local so this file stays portable.
if filereadable(expand('~/.vimrc.local'))
  source ~/.vimrc.local
endif

" vim: set foldmethod=marker ts=2 sw=2 et:
