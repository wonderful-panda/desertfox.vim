let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('desertfox')
let s:vital = {
      \  'Filepath': s:V.import('System.Filepath'),
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
          \ 'basedir': desertfox#path#normalize(fnamemodify(bufname('%'), ':p:h')),
          \ }
  endif
  return a:context.source__sphinx
endfunction "}}}

function! desertfox#toggle_path() abort "{{{
  try
    let proj = desertfox#current_project()
    if empty(proj.root)
      throw 'Sphinx: project not found'
    endif
    let basedir = desertfox#path#normalize(expand('%:p:h'))
    let [bufnum, lnum, col, off] = getpos('.')
    let line = getline(lnum)
    let path = expand('<cfile>')
    let len = len(path)
    if empty(path)
      return
    endif
    let altpath = proj.toggle_path(basedir, path)
    if empty(altpath)
      return
    endif
    let start = stridx(line, path) 
    while start + len < col
      let start = stridx(line, path, start + len)
    endwhile
    call setline(lnum, (start ? line[:start - 1] : '') . altpath . line[start + len :])
    call setpos('.', [bufnum, lnum, start + len(altpath), off])
  catch /^Sphinx:/
    echohl ErrorMsg | echomsg v:exception | echohl None
  endtry
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
