" PLUGINS ----------------------------------------------------------- {{{
" Plugin

" }}}
syntax on		" turn on syntax highlighting

" SET COMMANDS -------------------------------------------------- {{{
set expandtab             " expand tabs into spaces
set autoindent	          " auto-indent new lines
set smartindent	          " return ending brackets to proper location
set softtabstop=2         " indentation level of soft-tabs
set tabstop=2             " indentation level of normal tabs
set shiftwidth=2	  " how many columns to re-indent with << and >>
set showmatch		    " show matching brackets
set incsearch		    " find as you type a search

set nobackup        " do not save backup files
set history=1000    " set the commands to save in history - default is 20.
set wildmenu        " enable auto completion menu after pressing TAB.

set wildmode=list:longest  " Make wildmenu behave like similar to Bash completion.

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
" }}}

" MAPPINGS ------------------------------------------------------------ {{{
" Shift key fixes
cmap W w
cmap WQ wq
cmap wQ wQ
cmap Q q

" visual shifting (does not exit visual mode)
vnoremap < <gv
vnoremap > >gv
" }}}

" VIMSCRIPT ----------------------------------------------------------- {{{
augroup filtype_vim
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}


