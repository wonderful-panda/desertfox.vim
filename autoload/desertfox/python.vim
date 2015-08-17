let s:save_cpo = &cpo
set cpo&vim

function! s:command_name() abort "{{{
  return has('python') ? 'python' : 'python3'
endfunction "}}}

function! s:exec(script, ...) abort "{{{
  exec s:command_name() . ' ' . a:script
endfunction "}}}

function! s:eval(script, ...) abort "{{{
  if has('python')
    return pyeval(a:script)
  else
    return py3eval(a:script)
  endif
endfunction "}}}

let s:scriptdir = expand('<sfile>:p:h')
let s:imported = 0

function! s:setup_pythonmodule() abort "{{{
  if !has('python') && !has('python3')
    throw 'Sphinx: Python must be installed'
  endif
  if s:imported
    return
  endif
  let s:imported = 1
  call s:exec('
        \import vim, sys, os;
        \sys.path.insert(0, os.path.join(vim.eval("s:scriptdir"), "python"));
        \import desertfox')
endfunction "}}}

function! desertfox#python#save_clipboard_image(path) abort "{{{
  call s:setup_pythonmodule()
  let [ret, msg] = s:eval("desertfox.save_clipboard_image(vim.eval('a:1'))", a:path)
  if ret != 0
    throw 'Sphinx: ' . msg
  endif
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
