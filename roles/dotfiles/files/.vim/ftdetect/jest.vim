autocmd FileType * call s:Test()

function! s:Test()
  if match(&filetype, '\v<javascript|javascriptreact|typescript|typescriptreact>') == -1
    return
  endif

  if match(&filetype, '\v<jest>') != -1
    return
  endif
<<<<<<< HEAD
<<<<<<< HEAD
  if match(l:file, '\v(_spec|Spec|\.spec|-test|\.test)\.(js|jsx|ts|tsx)$') != -1
||||||| merged common ancestors
  if match(l:file, '\v(_spec|Spec|-test|\.test)\.(js|ts)$') != -1
=======

  let l:file=expand('<afile>')

  if match(l:file, '\v(_spec|Spec|-test|\.test)\.(js|jsx|ts|tsx)$') != -1 ||
        \ match(l:file, '\v/__tests__|tests?/.+\.(js|jsx|ts|tsx)$') != -1
>>>>>>> upstream/master
||||||| merged common ancestors
  if match(l:file, '\v(_spec|Spec|-test|\.test)\.(js|ts)$') != -1
=======

  let l:file=expand('<afile>')

  if match(l:file, '\v(_spec|Spec|-test|\.test)\.(js|jsx|ts|tsx)$') != -1 ||
        \ match(l:file, '\v/__tests__|tests?/.+\.(js|jsx|ts|tsx)$') != -1
>>>>>>> upstream/master
    noautocmd set filetype+=.jest
  endif
endfunction
