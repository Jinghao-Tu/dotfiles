augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,CmdlineLeave,WinEnter *
        \ if &number && mode() !=# 'i' |
        \   set relativenumber |
        \ endif
  autocmd BufLeave,FocusLost,InsertEnter,CmdlineEnter,WinLeave *
        \ if &number |
        \   set norelativenumber |
        \ endif
augroup END
