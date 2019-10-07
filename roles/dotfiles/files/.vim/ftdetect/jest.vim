autocmd FileType javascript,typescript call s:Test()

function s:Test()
  let l:file=expand('<afile>')
  " let l:filetype=expand('<amatch>')
  if match(&filetype, '\v<jest>') != -1
    return
  endif
  if match(l:file, '\v(_spec|Spec|\.spec|-test|\.test)\.(js|jsx|ts|tsx)$') != -1
    noautocmd set filetype+=.jest
  endif
endfunction
