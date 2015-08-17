let s:save_cpo = &cpo
set cpo&vim

let s:source = {
      \ 'name': 'sphinx',
      \ 'kind': 'manual',
      \ 'rank': 100,
      \ 'filetypes': { 'rst' : 1},
      \ }

function! neocomplete#sources#sphinx#define() abort
  return s:source
endfunction

let s:directives = {
      \ 'image':      ['alt', 'height', 'width', 'scale', 'align', 'target'],
      \ 'figure':     ['alt', 'height', 'width', 'scale', 'align', 'target', 'figwidth', 'figclass'],
      \ 'table':      ['class'],
      \ 'list-table': ['class', 'widths', 'header-rows', 'stub-columns'],
      \ 'code':       ['number-lines'],
      \ 'code-block': ['linenos'],
      \ 'attention':  ['class', 'name'],
      \ 'caution':    ['class', 'name'],
      \ 'danger':     ['class', 'name'],
      \ 'error':      ['class', 'name'],
      \ 'hint':       ['class', 'name'],
      \ 'important':  ['class', 'name'],
      \ 'note':       ['class', 'name'],
      \ 'tip':        ['class', 'name'],
      \ 'warning':    ['class', 'name'],
      \ 'admonition': ['class', 'name'],
      \ }

"
" Core
"
let s:get_complete_position_funcs = {} " get_complete_position functions of each kind
let s:gather_candidates_funcs = {} " gather_candidates functions of each kind

function! s:source.get_complete_position(context) abort "{{{
  let input = a:context.input[:col('.') - 1]
  let spctx= {'kind': ''}
  let a:context.source__sphinx = spctx
  for kind in keys(s:get_complete_position_funcs)
    let pos = s:get_complete_position_funcs[kind](input, spctx)
    if pos >= 0
      let spctx.kind = kind
      return pos
    endif
  endfor
  return -1
endfunction "}}}

function! s:source.gather_candidates(context) abort "{{{
    if !has_key(a:context, 'source__sphinx')
        return []
    endif
    let spctx = a:context.source__sphinx
    if empty(spctx.kind)
      return []
    else
      return s:gather_candidates_funcs[spctx.kind](spctx)
    endif
endfunction "}}}

"
" For directive completion
"
function! s:get_complete_position_funcs.directive(input, ...) abort "{{{
  " return complete position when inputting directive name
  " .. imag|
  "    ^
  return match(a:input, '\v\C((^|\s)\.\.\s+)\zs[a-z0-9\-]*$')
endfunction "}}}

function! s:gather_candidates_funcs.directive(...) abort "{{{
  return map(sort(keys(s:directives)), 
             \ '{"word" : v:val . "::", "menu" : "[sphinx]" }')
endfunction "}}}

"
" For image file path completion
"
function! s:get_complete_position_funcs.image(input, ...) abort "{{{
  " return complete position when inputting image path
  " .. image:: /_sta|
  "            ^
  return match(a:input, '\v\C((^|\s)\.\.\s+)(image|figure)::\s+\zs[^*?: \s]*$')
endfunction "}}}

function! s:gather_candidates_funcs.image(...) abort "{{{
  let proj = desertfox#current_project()
  let images = proj.gather_images(expand('%:p:h'))
  return map(images, '{"word" : v:val.disppath, "menu" : "[sphinx]" }')
endfunction "}}}

"
" For directive option completion
"
function! s:get_complete_position_funcs.directiveoption(input, sphinxcontext) abort "{{{
  " return complete position when inputting image path
  " .. image:: sample.png
  "     :width: 100%
  "     :hei|
  "     ^
  let start = match(a:input, '\v\C\s+:[a-z0-9\-]*$')
  if start < 0
    return -1
  endif
  let pos = stridx(a:input, ':', start)
  let lineno = line('.')
  let usedoptions = {}

  " search existing directive options upward
  let directiveline = ''
  while 1 < lineno
    let lineno -= 1
    let line = getline(lineno)
    let opt = matchstr(line, '\v^:\zs([a-z0-9\-]+)\ze:', pos)
    if !empty(opt)
      let usedoptions[opt] = 1
    else
      let directiveline = line
      break
    endif
  endwhile

  " get directive name
  "
  " NOTE: In simple table, two or more directives can exist in same line
  " === =================== =====================
  " 1   .. image:: xxx.png  .. image:: yyy.png
  "        :width: 100%        :width: 80%
  " === =================== =====================
  let directive = ''
  while start < pos
    let dp = match(directiveline, '\v\C(^|\s)\zs\.\.\s+[a-z0-9\-]+::', start)
    if dp < 0 || pos <= dp
      break
    else
      let matches = matchlist(directiveline, '\v\C\.\.\s+([a-z0-9\-]+)::', dp)
      let start = dp + len(matches[0])
      let directive = matches[1]
    endif
  endwhile
  if !empty(directive)
    let a:sphinxcontext.directive = directive
    let a:sphinxcontext.usedoptions = usedoptions
    return pos
  else
    return -1
  endif
endfunction "}}}

function! s:gather_candidates_funcs.directiveoption(sphinxcontext) abort "{{{
  let options = deepcopy(get(s:directives, a:sphinxcontext.directive, []))
        \
  let options = sort(filter(options, 
        \                   '!has_key(a:sphinxcontext.usedoptions, v:val)'))
  if empty(options)
    return []
  endif
  return map(options, '{"word": ":" . v:val . ":", "menu": "[sphinx]" }')
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: foldmethod=marker
