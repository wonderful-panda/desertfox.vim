let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('desertfox')
let s:vital = {
      \  'Filepath': s:V.import('System.Filepath')
      \ }

function! desertfox#vital() abort
  return s:vital
endfunction

function! desertfox#current_project() abort "{{{
  if !has_key(b:, 'desertfox_project')
    let b:sphinx_project = desertfox#project#find(expand('%'))
  endif
  return b:sphinx_project
endfunction "}}}

function! desertfox#setup_unite_context(context) abort "{{{
  if !has_key(a:context, 'source__sphinx')
    let a:context.source__sphinx = {
          \ 'proj': desertfox#current_project(),
          \ 'bufname': bufname('%')
          \ }
  endif
  return a:context.source__sphinx
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
