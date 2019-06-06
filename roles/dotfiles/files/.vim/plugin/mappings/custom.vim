autocmd FileType typescript setlocal formatprg=eslint\ --parser\ typescript

let g:ale_linters = {
\   'javascript': ['eslint', 'prettier'],
\   'typescript': ['tsserver', 'tslint'],
\   'vue': ['eslint']
\}

let g:ale_fixers = {
\    'javascript': ['eslint', 'prettier'],
\    'typescript': ['prettier'],
\    'vue': ['eslint'],
\    'scss': ['prettier'],
\    'css': ['prettier'],
\    'html': ['prettier']
\}
let g:ale_fix_on_save = 1
