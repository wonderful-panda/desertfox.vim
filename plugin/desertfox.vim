let s:save_cpo = &cpo
set cpo&vim

let g:desertfox#image_dirnames = ['images', 'figures', '_static']
let g:desertfox#image_ext = 'png'
let g:desertfox#project_search_depth = 5

let &cpo = s:save_cpo
unlet s:save_cpo
