" Plugin management for terminal Vim.
" Install vim-plug first, then run :PlugInstall.
" Check runtimepath so both user-local and system package installs work.

if empty(globpath(&runtimepath, 'autoload/plug.vim'))
  echohl WarningMsg
  echom 'vim-plug is not installed.'
  echohl None
  finish
endif

call plug#begin(expand('~/.vim/plugged'))

Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }

call plug#end()
