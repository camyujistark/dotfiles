function! s:require(condition, message)
  if a:condition
    call health#report_ok(a:message)
  else
    call health#report_error(a:message)
  endif
endfunction

function! health#wincent#check() abort
  call health#report_start('Wincent')
  call s:require(has('ruby'), 'Has Ruby support')
endfunction
