let s:save_cpo = &cpo
set cpo&vim

let g:sphinx_image_dirnames = ['images', 'figures', '_static']
let g:sphinx_image_ext = 'png'
let g:sphinx_root_dir_search_depth = 5

let &cpo = s:save_cpo
unlet s:save_cpo
