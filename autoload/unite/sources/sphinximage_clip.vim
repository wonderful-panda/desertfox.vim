let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \ 'name': 'sphinx/image/clip',
      \ 'hooks': {},
      \ 'action_table': {},
      \ 'default_action': 'save'
      \ }

function! s:source.hooks.on_init(args, context) abort "{{{
  call desertfox#setup_unite_context(a:context)
endfunction "}}}

function! s:source.change_candidates(args, context) abort "{{{
  let sphinxcontext = desertfox#setup_unite_context(a:context)
  let proj = sphinxcontext.proj
  if empty(a:context.input)
    return []
  endif
  let filename = a:context.input . '.' . g:desertfox#image_ext
  let candidates = [
        \ {'word': filename, 
        \  'abbr': '[new image] ' . filename,
        \  'action__path': sphinxcontext.basedir . '/' . filename,
        \  'kind': 'file',
        \ }]
  if !empty(proj.image_dirname)
    call add(candidates, 
        \ {'word': '/' . proj.image_dirname . '/' . filename, 
        \  'abbr': '[new image] /' . proj.image_dirname . '/' . filename,
        \  'action__path': proj.image_dir . '/' . filename,
        \  'kind': 'file',
        \ })
  endif
  return candidates
endfunction "}}}

"
" Actions
"
let s:source.action_table.save = {
      \ 'description' : 'save clipboard image',
      \ }

let s:source.action_table.insert_image = {
      \ 'description' : 'save clipboard image and insert image directive',
      \ }

let s:source.action_table.insert_figure = {
      \ 'description' : 'save clipboard image and insert figure directive',
      \ }

function! s:save_clipboard_image_with_confirm(path) abort "{{{
  if filereadable(a:path)
    let yn = input(fnamemodify(a:path, ':t') . ' already exists. Overwrite? : ')
    redraw
    if yn !~ '\v^y(es)?$'
      echo 'Cancelled.'
      return 0
    endif
  endif
  call desertfox#python#save_clipboard_image(a:path)
  echo 'Saved: ' . a:path
  return 1
endfunction "}}}

function! s:source.action_table.save.func(candidate) abort "{{{
  try
    call s:save_clipboard_image_with_confirm(a:candidate.action__path)
  catch /Sphinx:/
    echohl ErrorMsg | echomsg v:exception | echohl None
  endtry
endfunction "}}}

function! s:source.action_table.insert_image.func(candidate) abort "{{{
  try
    if s:save_clipboard_image_with_confirm(a:candidate.action__path)
      call unite#sources#sphinximage#insert_image(a:candidate)
    endif
  catch /Sphinx:/
    echohl ErrorMsg | echomsg v:exception | echohl None
  endtry
endfunction "}}}

function! s:source.action_table.insert_figure.func(candidate) abort "{{{
  try
    if s:save_clipboard_image_with_confirm(a:candidate.action__path)
      call unite#sources#sphinximage#insert_figure(a:candidate)
    endif
  catch /Sphinx:/
    echohl ErrorMsg | echomsg v:exception | echohl None
  endtry
endfunction "}}}

function! unite#sources#sphinximage_clip#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
