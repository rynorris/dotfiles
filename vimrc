set nocompatible

"------------------------------------------------------------------------------
" Vim-Plug for plugin management.
"------------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')

" Personal
let g:plug_url_format = 'git@github.com:%s.git'
Plug 'DiscoViking/CtrlPGtags'
Plug 'DiscoViking/AutoComment'
Plug 'DiscoViking/rainbow'
unlet g:plug_url_format

" Navigation
Plug 'kien/ctrlp.vim'
Plug 'JazzCore/ctrlp-cmatcher', { 'do': './install.sh' }
Plug 'rking/ag.vim'
Plug 'vim-scripts/gtags.vim'

" Editing
Plug 'SirVer/ultisnips'
Plug 'Valloric/YouCompleteMe', { 'do': './install.sh', 'for': ['c', 'python'] }
autocmd! User YouCompleteMe call youcompleteme#Enable()

" Informational
Plug 'scrooloose/syntastic'
Plug 'majutsushi/tagbar'

" Source control
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'

" Visual
Plug 'bling/vim-airline'
Plug 'chriskempson/vim-tomorrow-theme'

" Languages
Plug 'klen/python-mode', { 'for': 'python' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'fatih/vim-go', { 'for': 'go' }

" Other
Plug 'Shougo/vimproc.vim', { 'do': 'make' }

call plug#end()

"------------------------------------------------------------------------------
" General.
"------------------------------------------------------------------------------

" Tab settings.
set softtabstop=2
set shiftwidth=2
set expandtab
filetype plugin indent on

" When creating a new line inside open brackets, match the indent of the
" brackets.
set cino+=(0

" Search settings.
set incsearch  "Search as you type
set ignorecase "Ignore case by default
set smartcase  "Ignore case if input string all lower-case

" Tagging settings.
set csprg=gtags-cscope  "Use gtags-cscope instead of cscope for tagging.
" Add GTAGS tag database so cscope will use it.
exe "silent! cs add " . expand("$CB_ROOT/GTAGS")
set csverb
set cst                 "Makes cscope tags play nice with the tag stack.

" Make backspace behave as expected.
set backspace=indent,eol,start

" Map W and Q to w and q so no more accidental failure to save/quit nonsense.
command! W w
command! Q q
command! WQ wq
command! Wq wq

"------------------------------------------------------------------------------
" Visual
"------------------------------------------------------------------------------
syntax on

" Keep 3 lines below/above cursor visible at all times.
set scrolloff=3

" Don't highlight errors in shell scripts. Makes it play nice with my
" custom rainbow parentheses settings for shell.
let g:sh_no_error = 1

" Use c syntax highlighting for .h files
let g:c_syntax_for_h = 1

" Color scheme - override background to be transparent.
colorscheme Tomorrow-Night
hi Normal ctermbg=none

" Rainbow Parentheses
let g:rainbow_active = 1

" Line numbers
set relativenumber
set colorcolumn=80

" Highlight the current line.
set cursorline

" Set window title
set titlestring=%t%(\ %M%)%(\ (%{expand(\"%:p:h\")})%)%(\ %a%)\ -\ %{v:servername}
set title

"------------------------------------------------------------------------------
" Airline configuration.
"------------------------------------------------------------------------------
let g:airline_powerline_fonts = 1
set laststatus=2

"------------------------------------------------------------------------------
" Ctrl-P options:
"------------------------------------------------------------------------------
set wildignore+=*.tmp,*.swp,*.so,*.zip,*.o,*.d
let g:ctrlp_max_files = 910000
let g:ctrlp_use_caching = 1
let g:ctrlp_switch_buffer = 'T'
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_dotfiles = 0
let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'

" Use the cmatcher to perform matching. Much faster!
" Necessary to use CtrlPGtags.
let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }

"------------------------------------------------------------------------------
" YCM Setup
"------------------------------------------------------------------------------
let g:ycm_add_preview_to_completeopt=0
let g:ycm_show_diagnostics_ui = 0 " Disabled so we can use Syntastic checking in C

" Fix YCM/Ultisnips compatibility
function! g:UltiSnips_Complete()
  call UltiSnips#ExpandSnippet()
  if g:ulti_expand_res == 0
    if pumvisible()
      return "\<C-n>"
    else
      call UltiSnips#JumpForwards()
      if g:ulti_jump_forwards_res == 0
        return "\<TAB>"
      endif
    endif
  endif
  return ""
endfunction

au BufEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger . " <C-R>=g:UltiSnips_Complete()<cr>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsListSnippets="<c-e>"
" this mapping Enter key to <C-y> to chose the current highlight item
" and close the selection list, same as other IDEs.
" CONFLICT with some plugins like tpope/Endwise
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

"------------------------------------------------------------------------------
" Python mode settings
"------------------------------------------------------------------------------
let g:pymode_folding=0 "Don't do folding.
let g:pymode_rope=0    "Disables rope. This was causing huge lags in python files.

"------------------------------------------------------------------------------
" Syntastic settings
"------------------------------------------------------------------------------
let g:syntastic_python_checkers=['python']
let g:syntastic_c_checkers=[]

"------------------------------------------------------------------------------
" Key Binds
"------------------------------------------------------------------------------
noremap <leader>g :CtrlPGtags<CR>
noremap <leader>s :cs<space>f<space>s<space>

" Override for testing Gtags without cscope
nmap <C-\>s :Gtags -r <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :cs f g <C-r><C-w><CR>
nmap <C-\>n :cn<CR>
nmap <C-\>p :cp<CR>

"------------------------------------------------------------------------------
" HARD MODE
"------------------------------------------------------------------------------
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
nnoremap j gj
nnoremap k gk

"------------------------------------------------------------------------------
" Auto-format go files on save.
"------------------------------------------------------------------------------
autocmd FileType go autocmd BufWritePre <buffer> Fmt

if executable("xclip")
  " Put contents of unnamed register into clipboard.
  command! Clip call system('xclip -i -selection clipboard', @")
  " Paste contents of clipboard into buffer.
  command! Clop put = system('xclip -o -selection clipboard')
endif

"------------------------------------------------------------------------------
" Functions to right-align a line of text.
"------------------------------------------------------------------------------
function! Strip( text )
  return substitute(a:text, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction

function! RightAlign()
  let text = Strip(getline('.'))
  let text = substitute(text, '^', repeat(' ', 79-len(text)), '')
  exe 's/.*/' . text . '/'
endfunction

command! RightAlign :call RightAlign()
nmap <leader>l :RightAlign<CR>

"------------------------------------------------------------------------------
" Enable mouse control for idle scrolling.
" Selectively map only the mouse buttons we want.
"------------------------------------------------------------------------------
"set mouse=a
map <ScrollWheelUp> 4<C-Y>
map <ScrollWheelDown> 4<C-E>
"map <LeftMouse> <nop>

" Double left click goes to definition of tag under cursor.
"map <2-LeftMouse> :cs f g <C-R>=expand("<cword>")<CR><CR><ESC>
map <2-LeftMouse> <nop>
map <3-LeftMouse> <nop>
"map <LeftDrag> <nop>
"map <LeftRelease> <nop>

map <RightMouse> <nop>
map <2-RightMouse> <nop>
map <3-RightMouse> <nop>
map <RightDrag> <nop>
map <RightRelease> <nop>

"------------------------------------------------------------------------------
" Open function definition in window to the right.
"------------------------------------------------------------------------------
function! RightDef()
  let l:fname = expand("<cword>")
  rightbelow vert new
  try
    exe "cs f g " . l:fname
  catch
    quit "If we failed to find the tag, close the window we just opened.
    redraw "Force a redraw now so that the next echo won't get overwritten.
    echom "Didn't find definition of " . l:fname
  endtry
endfunction
nmap <silent> <C-\>r :call RightDef()<CR>

"------------------------------------------------------------------------------
" Strip trailing whitespace on save.
"------------------------------------------------------------------------------
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

autocmd FileType c,cpp,java,php,ruby,python,go,make,vim,sh autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

" Also highlight trailing whitespace so we can spot it in other filetypes.
match Todo /\s\+$/
hi Todo ctermbg=1 ctermfg=7

"------------------------------------------------------------------------------
" Window swap commands.
"------------------------------------------------------------------------------
function! MarkWindowSwap()
  let g:markedWinNum = winnr()
endfunction

function! DoWindowSwap()
  "Mark destination
  let curNum = winnr()
  let curBuf = bufnr( "%" )
  exe g:markedWinNum . "wincmd w"
  "Switch to source and shuffle dest->source
  let markedBuf = bufnr( "%" )
  "Hide and open so that we aren't prompted and keep history
  exe 'hide buf' curBuf
  "Switch to dest and shuffle source->dest
  exe curNum . "wincmd w"
  "Hide and open so that we aren't prompted and keep history
  exe 'hide buf' markedBuf
endfunction


nmap <silent> <leader>mw :call MarkWindowSwap()<CR>
nmap <silent> <leader>pw :call DoWindowSwap()<CR>

"------------------------------------------------------------------------------
" Mouse scrolling
"------------------------------------------------------------------------------
function! SetPos()
  let g:oldline = winline()
  let g:oldcol = wincol()
endfunction

function! ScrollWindow()
  let l:newline = winline()
  let l:newcol = wincol()
  let l:linediff = l:newline - g:oldline
  let l:coldiff = l:newcol - g:oldcol
  let g:oldline = l:newline
  let g:oldcol = l:newcol

  if (l:linediff > 0)
    exec "norm " . l:linediff . "\<C-Y>"
    exec "norm " . l:linediff . "k"
  else
    if (l:linediff < 0)
      exec "norm " . -l:linediff . "\<C-E>"
      exec "norm " . -l:linediff . "j"
    endif
  endif

  if (l:coldiff > 0)
    exec "norm " . l:coldiff . "zh"
    exec "norm " . l:coldiff . "h"
  else
    if (l:coldiff < 0)
      exec "norm " . -l:coldiff . "zl"
      exec "norm " . -l:coldiff . "l"
    endif
  endif
endfunction

"------------------------------------------------------------------------------
" Function for sourcing a file if it exists.
"------------------------------------------------------------------------------
function! Source(file)
  let l:filename = expand(a:file)
  if filereadable(l:filename)
    exec "silent source" . fnameescape(l:filename)
  endif
endfunction

"------------------------------------------------------------------------------
" If there's a local vimrc on this system, load it.
" This is designed to allow for system-specific customization.
"------------------------------------------------------------------------------
call Source("~/.vimrc_local")
