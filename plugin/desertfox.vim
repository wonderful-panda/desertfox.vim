let s:save_cpo = &cpo
set cpo&vim

let g:desertfox#image_dirnames = ['images', 'figures', '_static']
let g:desertfox#image_ext = 'png'
let g:desertfox#project_search_depth = 5

nnoremap <silent> <Plug>(desertfox_toggle_path) :<C-u>call desertfox#toggle_path()<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
