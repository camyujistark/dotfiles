if has('folding')
  setlocal nofoldenable
endif

call wincent#functions#spell()

" This slows down initialization but it's too damn useful not to have it right
" from the start.
" call wincent#autocomplete#deoplete_init()
