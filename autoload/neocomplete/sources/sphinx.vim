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

" directives {{{
let s:directives = {
      \ 'image': {
      \   'complete_func': 's:gather_images',
      \   'options': ['alt', 'height', 'width', 'scale', 'align', 'target'],
      \ },
      \ 'figure': {
      \   'complete_func': 's:gather_images',
      \   'options': ['alt', 'height', 'width', 'scale', 'align', 'target', 'figwidth', 'figclass'],
      \ },
      \ 'table':      {'options': ['class']},
      \ 'list-table': {'options': ['class', 'widths', 'header-rows', 'stub-columns']},
      \ 'code':       {'options': ['number-lines']},
      \ 'code-block': {'options': ['linenos']},
      \ 'attention':  {'options': ['class', 'name']},
      \ 'caution':    {'options': ['class', 'name']},
      \ 'danger':     {'options': ['class', 'name']},
      \ 'error':      {'options': ['class', 'name']},
      \ 'hint':       {'options': ['class', 'name']},
      \ 'important':  {'options': ['class', 'name']},
      \ 'note':       {'options': ['class', 'name']},
      \ 'tip':        {'options': ['class', 'name']},
      \ 'warning':    {'options': ['class', 'name']},
      \ 'admonition': {'options': ['class', 'name']},
      \ }
"}}}

" markups {{{
let s:markups = {
      \ 'any':  {},
      \ 'ref': {}, 
      \ 'doc': {'complete_func': 's:gather_rest_texts'},
      \ 'download': {},
      \ 'numref': {},
      \ 'abbr': {},
      \ 'command': {},
      \ 'file': {},
      \ 'guilabel': {},
      \ 'kbd': {},
      \ 'mailheader': {},
      \ 'makevar': {},
      \ 'manpage': {},
      \ 'menuselection': {},
      \ 'mimetype': {},
      \ 'program': {},
      \ 'regexp': {},
      \ 'samp': {},
      \  }
"}}}
        
"
" Core
"
let s:get_complete_position_funcs = {} " get_complete_position functions of each kind
let s:gather_candidates_funcs = {} " gather_candidates functions of each kind

function! s:source.get_complete_position(context) abort "{{{
  let input = a:context.input[:col('.') - 1]
  let spctx= {'kind': ''}
  let a:context.source__sphinx = spctx
  " 'directiveoption' must precede 'markup'
  for kind in ['directive', 'directiveoption', 'markup']
    let [pos, complete_func] = s:get_complete_position_funcs[kind](input, spctx)
    if pos >= 0
      let spctx.kind = kind
      let spctx.complete_func = complete_func
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
    let complete_func = get(spctx, 'complete_func', '')
    if !empty(complete_func)
      return function(complete_func)(spctx)
    else
      return []
    endif
endfunction "}}}

"
" For directive completion
"
function! s:get_complete_position_funcs.directive(input, ...) abort "{{{
  " return complete position when inputting directive name or argument
  " .. imag|
  "    ^
  " .. image:: ../_static
  "            ^
  let matches = matchlist(a:input, '\v\C^(%(.*\s)?\.\.\s+)([a-z0-9\-]*)(::\s+)?\ze[^:]*$')
  if empty(matches)
    return [-1, '']
  endif
  if len(matches[3]) == 0
    return [len(matches[1]), 's:gather_directives']
  else
    let directive = matches[2]
    if empty(directive)
      return [-1, '']
    endif
    return [len(matches[0]), get(get(s:directives, directive, {}), 'complete_func', '')]
  endif
endfunction "}}}

function! s:gather_directives(...) abort "{{{
  return map(sort(keys(s:directives)), 
             \ '{"word" : v:val . "::", "menu" : "[sphinx]" }')
endfunction "}}}

function! s:gather_images(...) abort "{{{
  let proj = desertfox#current_project()
  let images = proj.gather_images(desertfox#path#normalize(expand('%:p:h')))
  return s:files_to_candidates(images, 0)
endfunction "}}}

"
" For directive option completion
"
function! s:get_complete_position_funcs.directiveoption(input, spctx) abort "{{{
  " return complete position when inputting directive option
  " .. image:: sample.png
  "     :width: 100%
  "     :hei|
  "     ^
  let start = match(a:input, '\v\C\s+:[a-z0-9\-]*$')
  if start < 0
    return [-1, '']
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
    let a:spctx.directive = directive
    let a:spctx.usedoptions = usedoptions
    return [pos, 's:gather_directiveoptions']
  else
    return [-1, '']
  endif
endfunction "}}}

function! s:gather_directiveoptions(spctx) abort "{{{
  let directive = get(s:directives, a:spctx.directive, {})
  let options = sort(filter(deepcopy(get(directive, 'options', [])),
        \                   '!has_key(a:spctx.usedoptions, v:val)'))
  if empty(options)
    return []
  endif
  return map(options, '{"word": ":" . v:val . ":", "menu": "[sphinx]" }')
endfunction "}}}

"
" For inline markup completion
"
function! s:get_complete_position_funcs.markup(input, ...) abort "{{{
  " return complete position when inputting inline markup
  " .. :doc
  "    ^
  " .. :doc:`../foo
  "          ^
  let matches = matchlist(a:input, '\v\C^(.*[^\k:])?:([a-z0-9\-]*)(:`)?\ze%(\\`|[^`])*$')
  if empty(matches)
    return [-1, '']
  endif
  if empty(matches[3])
    return [len(matches[1]), 's:gather_markups']
  else
    let markup = matches[2]
    if len(markup) == 0
      return [-1, '']
    endif
    return [len(matches[0]), get(get(s:markups, markup, {}), 'complete_func', '')]
  endif
endfunction "}}}

function! s:gather_markups(...) abort "{{{
  return map(keys(s:markups), '{"word": ":" . v:val . ":", "menu": "[sphinx]" }')
endfunction "}}}

function! s:gather_rest_texts(...) abort "{{{
  let proj = desertfox#current_project()
  let files = proj.gather_rest_texts(desertfox#path#normalize(expand('%:p:h')))
  return s:files_to_candidates(files, 1)
endfunction "}}}

function! s:files_to_candidates(files, strip_extension) abort "{{{
  let candidates = map(a:files, '{
        \     "word": !empty(v:val.localpath) && v:val.relpath[:2] ==# "../"
        \              ? v:val.localpath : v:val.relpath,
        \     "menu": "[sphinx]"
        \ }')
  if a:strip_extension
    call map(candidates, '{
          \ "word": desertfox#path#strip_ext(v:val.word),
          \ "menu": v:val.menu,
          \ }')
  endif
  return candidates
endfunction "}}}

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: foldmethod=marker
