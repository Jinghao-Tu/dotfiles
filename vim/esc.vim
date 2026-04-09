let s:double_esc_window = 0.3
let s:last_normal_esc = reltime()

function! s:maybe_clear_search_highlight() abort
  let l:elapsed = reltimefloat(reltime(s:last_normal_esc))
  let s:last_normal_esc = reltime()
  if v:hlsearch && l:elapsed < s:double_esc_window
    return ':nohlsearch' . "\<CR>"
  endif
  return "\<Esc>"
endfunction

function! s:install_normal_esc_map(...) abort
  " Kitty may break early <Esc> mappings during startup, so install this after VimEnter.
  silent! nunmap <Esc>
  nnoremap <silent><expr> <Esc> <SID>maybe_clear_search_highlight()
endfunction

augroup esc_mapping
  autocmd!
  if has('timers')
    autocmd VimEnter * call timer_start(100, function('<SID>install_normal_esc_map'))
  else
    autocmd VimEnter * call <SID>install_normal_esc_map()
  endif
augroup END
