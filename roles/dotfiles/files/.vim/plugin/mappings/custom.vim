autocmd FileType typescript setlocal formatprg=eslint\ --parser\ typescript

" let g:ale_linter_aliases = {'typescriptreact': 'typescript'}
"
" let g:ale_linters = {
" \   'javascript': ['prettier'],
" \   'typescript': ['tsserver', 'tslint'],
" \   'vue': ['eslint']
" \}
"
" let g:ale_fixers = {
" \    'javascript': ['eslint'],
" \    'typescript': ['prettier'],
" \    'vue': ['eslint'],
" \    'scss': ['prettier'],
" \    'html': ['prettier']
" \}

<<<<<<< Updated upstream
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
||||||| constructed merge base
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
\    'html': ['prettier']
\}

let g:ale_fix_on_save = 1
command! ALEToggleFixer execute "let g:ale_fix_on_save = get(g:, 'ale_fix_on_save', 0) ? 0 : 1"
=======
" let g:ale_fix_on_save = 1
" command! ALEToggleFixer execute "let g:ale_fix_on_save = get(g:, 'ale_fix_on_save', 0) ? 0 : 1"
>>>>>>> Stashed changes

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

" COC
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Remap keys for applying codeAction to the current buffer.
nmap <LocalLeader>a  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <LocalLeader>q  <Plug>(coc-fix-current)

nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<c-j>'
let g:UltiSnipsJumpBackwardTrigger = '<c-k>'
let g:UltiSnipsRemoveSelectModeMappings = 0

let g:coc_filetype_map = {
  \ '': 'html',
  \ 'javascript.react': 'javascriptreact',
  \ 'typescript.react': 'typescriptreact',
  \ 'typescript.jest': 'typescript',
  \ 'javascript.jest': 'javascript'
  \ }
