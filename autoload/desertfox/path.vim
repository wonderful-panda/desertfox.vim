let s:save_cpo = &cpo
set cpo&vim

let s:F = desertfox#vital().Filepath
let s:P = desertfox#vital().Prelude

function! desertfox#path#normalize(path) abort "{{{
  let ret = s:P.substitute_path_separator(a:path)
  return ret[-1:-1] == '/' ? ret[0:-2] : ret
endfunction "}}}

function! desertfox#path#are_same(name1, name2) abort "{{{
  if s:F.is_case_tolerant()
    return a:name1 ==? a:name2
  else
    return a:name1 ==~ a:name2
  endif
endfunction "}}}

function! desertfox#path#to_relative(basedir, path) abort "{{{
  let bnames = split(a:basedir, '/', 1)
  let pnames = split(a:path, '/', 1)
  while !empty(bnames) && !empty(pnames) && 
        \ desertfox#path#are_same(bnames[0], pnames[0])
    call remove(bnames, 0)
    call remove(pnames, 0)
  endwhile
  let newpath = join(pnames, '/')
  if s:F.is_absolute(newpath)
    return newpath
  else
    return repeat('../', len(bnames)) . newpath
  endif
endfunction "}}}

function! desertfox#path#strip_ext(path) abort "{{{
  return substitute(a:path, '\v\.[^.]+$', '', '')
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
