function! s:clipboard_text(regtype, lines) abort
  let l:data = join(a:lines, "\n")
  if a:regtype =~# '^V'
    let l:data .= "\n"
  endif
  return l:data
endfunction

function! s:clipboard_selection(reg) abort
  return a:reg ==# '*' ? 'primary' : 'clipboard'
endfunction

function! s:wayland_clipboard_available() abort
  return !empty($WAYLAND_DISPLAY) && executable('wl-copy') && executable('wl-paste')
endfunction

function! s:wayland_clipboard_copy(reg, regtype, lines) abort
  let l:cmd = 'wl-copy --type text/plain;charset=utf-8'
  if a:reg ==# '*'
    let l:cmd .= ' --primary'
  endif
  call system(l:cmd, <SID>clipboard_text(a:regtype, a:lines))
endfunction

function! s:wayland_clipboard_paste(reg) abort
  let l:cmd = 'wl-paste --no-newline'
  if a:reg ==# '*'
    let l:cmd .= ' --primary'
  endif
  return ['v', systemlist(l:cmd)]
endfunction

function! s:xclip_clipboard_available() abort
  return !empty($DISPLAY) && executable('xclip')
endfunction

function! s:xclip_clipboard_copy(reg, regtype, lines) abort
  let l:cmd = 'xclip -selection ' . <SID>clipboard_selection(a:reg)
  call system(l:cmd, <SID>clipboard_text(a:regtype, a:lines))
endfunction

function! s:xclip_clipboard_paste(reg) abort
  let l:cmd = 'xclip -selection ' . <SID>clipboard_selection(a:reg) . ' -o'
  return ['v', systemlist(l:cmd)]
endfunction

if exists('v:clipproviders')
  let v:clipproviders['dotfiles_wayland'] = {
        \ 'available': function('<SID>wayland_clipboard_available'),
        \ 'copy': {
        \   '+': function('<SID>wayland_clipboard_copy'),
        \   '*': function('<SID>wayland_clipboard_copy'),
        \ },
        \ 'paste': {
        \   '+': function('<SID>wayland_clipboard_paste'),
        \   '*': function('<SID>wayland_clipboard_paste'),
        \ },
        \ }
  let v:clipproviders['dotfiles_xclip'] = {
        \ 'available': function('<SID>xclip_clipboard_available'),
        \ 'copy': {
        \   '+': function('<SID>xclip_clipboard_copy'),
        \   '*': function('<SID>xclip_clipboard_copy'),
        \ },
        \ 'paste': {
        \   '+': function('<SID>xclip_clipboard_paste'),
        \   '*': function('<SID>xclip_clipboard_paste'),
        \ },
        \ }
  if <SID>wayland_clipboard_available() || <SID>xclip_clipboard_available()
    let &clipmethod = 'dotfiles_wayland,dotfiles_xclip'
    set clipboard=unnamedplus
  endif
endif
