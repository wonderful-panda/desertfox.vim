let s:save_cpo = &cpo
set cpo&vim

let s:project = {
      \ 'root': '',
      \ 'image_dirname': '',
      \ 'image_dir': '',
      \ }

function! s:project.to_localpath(abspath) abort "{{{
  if empty(self.root)
    return ''
  endif
  return '/' . desertfox#path#to_relative(self.root, a:abspath)
endfunction "}}}

function! s:project.relpath_to_localpath(basedir, relpath) abort "{{{
  if empty(self.root)
    return ''
  endif
  let abspath = simplify(a:basedir . '/' . a:relpath)
  return self.to_localpath(abspath)
endfunction "}}}

function! s:project.localpath_to_relpath(basedir, localpath) abort "{{{
  if empty(self.root)
    return ''
  endif
  return desertfox#path#to_relative(a:basedir, self.root . a:localpath)
endfunction "}}}

function! s:project.toggle_path(basedir, path) abort "{{{
  if a:path =~# '\v^/'
    return self.localpath_to_relpath(a:basedir, a:path)
  else
    return self.relpath_to_localpath(a:basedir, a:path)
  endif
endfunction "}}}

function! s:project.gather_images(basedir) abort "{{{
  let pattern = '*.' . g:desertfox#image_ext
  let files = glob(a:basedir . '/' . pattern, 0, 1)
  if !empty(self.image_dir)
    call extend(files, glob(self.image_dir . '/' . pattern, 0, 1))
  endif
  return map(map(files,  'desertfox#path#normalize(v:val)'), '{
        \ "abspath": v:val,
        \ "relpath": desertfox#path#to_relative(a:basedir, v:val),
        \ "localpath": self.to_localpath(v:val)
        \ }')
endfunction "}}}

function! s:find_root(curdir) abort "{{{
  let dir = a:curdir
  let depth = g:desertfox#project_search_depth
  while depth > 0 && !empty(dir)
    if filereadable(dir . '/conf.py')
      return desertfox#path#normalize(dir)
    endif
    let dir = fnamemodify(dir, ':h')
    let depth -= 1
  endwhile
  return ''
endfunction "}}}

function! s:find_image_dir(dirpath) "{{{
  for dirname in g:desertfox#image_dirnames
    if isdirectory(a:dirpath . '/' . dirname)
      return dirname
    endif
  endfor
  return ''
endfunction "}}}

function! desertfox#project#find(filepath) abort "{{{
  let project = deepcopy(s:project)
  let curdir = fnamemodify(a:filepath, ':p:h')
  let project.root = s:find_root(curdir)
  if !empty(project.root)
    let project.image_dirname = s:find_image_dir(project.root)
    if !empty(project.image_dirname)
      let project.image_dir = project.root . '/' . project.image_dirname
    endif
  endif
  return project
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
