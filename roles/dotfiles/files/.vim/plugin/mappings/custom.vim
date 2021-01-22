autocmd FileType typescript setlocal formatprg=eslint\ --parser\ typescript

let g:ale_linter_aliases = {'typescriptreact': 'typescript'}

let g:ale_linters = {
\   'javascript': ['prettier'],
\   'typescript': ['tsserver', 'tslint'],
\   'vue': ['eslint']
\}

let g:ale_fixers = {
\    'javascript': ['eslint'],
\    'typescript': ['prettier'],
\    'vue': ['eslint'],
\    'scss': ['prettier'],
\    'html': ['prettier'],
\    'php': ['php_cs_fixer']
\}

let g:ale_fix_on_save = 1
command! ALEToggleFixer execute "let g:ale_fix_on_save = get(g:, 'ale_fix_on_save', 0) ? 0 : 1"

" Load file with js alias on gf

set path=.,src
set suffixesadd=.js,.jsx,.ts,.tsx

function! LoadMainNodeModule(fname)
  return path
    let nodeModules = "./node_modules/"
    let packageJsonPath = nodeModules . a:fname . "/package.json"

    if filereadable(packageJsonPath)
        return nodeModules . a:fname . "/" . json_decode(join(readfile(packageJsonPath))).main
    else
        return nodeModules . a:fname
    endif
endfunction

set includeexpr=LoadMainNodeModule(v:fname)

