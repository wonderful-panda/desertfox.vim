let s:save_cpo = &cpo
set cpo&vim

let s:Filepath = desertfox#vital().Filepath

let s:source = {
      \ 'name': 'sphinx/images',
      \ 'action_table': {},
      \ 'default_action': 'insert_image'
      \ }

function! s:source.gather_candidates(args, context) abort "{{{
  let sphinxcontext = desertfox#setup_unite_context(a:context)
  let proj = sphinxcontext.proj
  let basedir = fnamemodify(sphinxcontext.bufname, ':p:h')
  let images = proj.gather_images(basedir)
  return map(images, '{
        \     "word": v:val.disppath,
        \     "action__path": v:val.abspath,
        \     "kind": "file",
        \     }')
endfunction "}}}

"
" Actions
"
function! unite#sources#sphinximages#insert_image(candidate) abort "{{{
  call s:insert_directive(a:candidate, 'image')
endfunction "}}}

function! unite#sources#sphinximages#insert_figure(candidate) abort "{{{
  call s:insert_directive(a:candidate, 'figure')
endfunction "}}}

function! s:insert_directive(candidate, directive) abort "{{{
  let candidate = deepcopy(a:candidate)
  let candidate.action__text = '.. ' . a:directive . ':: ' . candidate.word
  call unite#kinds#common#define().action_table.insert.func(candidate)
endfunction "}}}

let s:source.action_table.insert_image = {
      \ 'description' : 'insert image directive',
      \ 'func': function("unite#sources#sphinximages#insert_image"),
      \ }

let s:source.action_table.insert_figure = {
      \ 'description' : 'insert figure directive',
      \ 'func': function("unite#sources#sphinximages#insert_figure"),
      \ }

function! unite#sources#sphinximages#define()
  return s:source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
