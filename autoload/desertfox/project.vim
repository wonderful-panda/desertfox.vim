let s:save_cpo = &cpo
set cpo&vim

let s:Filepath = desertfox#vital().Filepath

let s:project = {
      \ 'root': '',
      \ 'image_dirname': '',
      \ }

function! s:project.gather_images(basedir) abort "{{{
  let pattern = '*.' . g:desertfox#image_ext
  let folders = [[a:basedir, '']]

  let files = map(sort(glob(s:Filepath.join(a:basedir, pattern), 0, 1)),
        \         '{"abspath": v:val, 
        \           "disppath": fnamemodify(v:val, ":t"),
        \          }')
  if !empty(self.root) && !empty(self.image_dirname)
    call extend(files, 
          \     map(sort(glob(s:Filepath.join(self.root, self.image_dirname, pattern), 0, 1)),
          \         '{"abspath": v:val, 
          \           "disppath": s:Filepath.join("", self.image_dirname, fnamemodify(v:val, ":t")),
          \          }'))
  endif
  return files
endfunction "}}}

function! s:find_root(curdir) abort "{{{
  let dir = a:curdir
  let depth = g:desertfox#project_search_depth
  while depth > 0 && !empty(dir)
    if filereadable(s:Filepath.join(dir, 'conf.py'))
      return dir
    endif
    let dir = fnamemodify(dir, ':h')
    let depth -= 1
  endwhile
  return ''
endfunction "}}}

function! s:find_image_dir(dirpath) "{{{
  for dirname in g:desertfox#image_dirnames
    if isdirectory(s:Filepath.join(a:dirpath, dirname))
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
  endif
  return project
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
