scriptencoding utf-8
"/**
" * @file quickfilesearch2.vim
" * @author naoyuki onishi <naoyuki1019 at gmail.com>
" * @version 1.0
" */

if exists('g:loaded_quickfilesearch2')
  finish
endif
let g:loaded_quickfilesearch2 = 1

let s:save_cpo = &cpo
set cpo&vim


if has("win32") || has("win95") || has("win64") || has("win16")
  let s:is_win = 1
  let s:ds = '\'
else
  let s:is_win = 0
  let s:ds = '/'
endif

if !exists('g:qsf_lsfile')
  let g:qsf_lsfile = '.lsfile'
endif

if !exists('g:qsf_maxline')
  let g:qsf_maxline = 200
endif

let s:debug = 1

"Move the cursor to quickfix window after search
if !exists('g:qsf_focus_quickfix')
  let g:qsf_focus_quickfix = 1
endif

"mkfile ***.sh ***.bat
if !exists('g:qsf_mkfile')
  if 1 == s:is_win
    let g:qsf_mkfile = '.lsfile.bat'
  else
    let g:qsf_mkfile = '.lsfile.sh'
  endif
endif
let g:qsf_automake = get(g:, 'qsf_automake', 1)
let g:qsf_automake_onetime = get(g:, 'qsf_automake_onetime', 1)
let g:qsf_ask_one = get(g:, 'qsf_ask_one', 1)

let s:bufnr = ''
let s:searchword = ''
let s:find_mkfile = 0
let s:lsfile_path = ''
let s:qsf_ask_one_flg = 0
let s:exec_confirm = 0
command! -nargs=* FS call quickfilesearch2#QFSFileSearch(<f-args>)
command! QFSFileSearch2 call quickfilesearch2#QFSFileSearchInput()
command! QFSMakeList call quickfilesearch2#QFSMakeList()

augroup quickfilesearch2#QFS
    autocmd!
    autocmd BufReadPost * call quickfilesearch2#QFSOnBufRead()
augroup END

function! quickfilesearch2#QFSOnBufRead()
  if 1 == g:qsf_automake && (0 == g:qsf_automake_onetime || (1 == g:qsf_automake_onetime && '' == s:lsfile_path))
    if 0 == g:qsf_ask_one || (1 == g:qsf_ask_one && 0 == s:qsf_ask_one_flg)
      call s:search_lsfile(fnamemodify(bufname(bufnr('%')), ':p:h'))
    endif
  endif

endfunction

function! s:search_lsfile(dir)
  let l:dir = a:dir

  if 1 == s:is_remote(l:dir)
    return ''
  endif

  if 1 == s:is_win
    if 3 == strlen(l:dir)
      let l:dir = l:dir[0:1]
    endif
  else
  endif

  let l:lsfile_path = fnamemodify(l:dir.s:ds.g:qsf_lsfile, ':p')
  if filereadable(l:lsfile_path)
    return l:dir.s:ds.g:qsf_lsfile
  endif

  let l:mkfile_path = fnamemodify(l:dir.s:ds.g:qsf_mkfile, ':p')
  if filereadable(l:mkfile_path)
    let s:find_mkfile = 1
    let l:res = s:exec_make(l:dir.s:ds)
    if 0 == l:res
      return l:dir.s:ds.g:qsf_lsfile
    elseif 2 == l:res
      return ''
    endif
  endif

  if 1 == s:is_win
    if 2 == strlen(l:dir)
      return ''
    endif
  else
    if '/' == l:dir
      return ''
    endif
  endif

  let l:dir = fnamemodify(l:dir.s:ds.'..'.s:ds, ':p:h')

  " Network file
  if l:dir == a:dir
    return ''
  endif

  " 念のため
  if 1 == s:is_win
    let l:match = matchstr(l:dir, '\V..\\..\\')
  else
    let l:match = matchstr(l:dir, '\V../../')
  endif
  if '' != l:match
    return ''
  endif

  return s:search_lsfile(l:dir)

endfunction


function! s:search_mkfile(dir)
  let l:dir = a:dir

  if 1 == s:is_remote(l:dir)
    return ''
  endif

  if 1 == s:is_win
    if 3 == strlen(l:dir)
      let l:dir = l:dir[0:1]
    endif
  else
  endif

  let l:mkfile_path = fnamemodify(l:dir.s:ds.g:qsf_mkfile, ':p')
  if filereadable(l:mkfile_path)
    let s:find_mkfile = 1
    return l:dir
  endif

  if 1 == s:is_win
    if 2 == strlen(l:dir)
      return ''
    endif
  else
    if '/' == l:dir
      return ''
    endif
  endif

  let l:dir = fnamemodify(l:dir.s:ds.'..'.s:ds, ':p:h')

  " Network file
  if l:dir == a:dir
    return ''
  endif

  " 念のため
  if 1 == s:is_win
    let l:match = matchstr(l:dir, '\V..\\..\\')
  else
    let l:match = matchstr(l:dir, '\V../../')
  endif
  if '' != l:match
    return ''
  endif

  return s:search_mkfile(l:dir)

endfunction

function! s:get_bufnr()

  let l:bufdir = ''

  let l:bufnr = bufnr('%')
  if getbufvar(l:bufnr, '&buftype') ==# ''
    let l:bufdir = fnamemodify(bufname(l:bufnr), ':p:h')
    if '' != l:bufdir
      return l:bufnr
    endif
  endif

  let l:bufnr = bufnr('#')
  if getbufvar(l:bufnr, '&buftype') ==# ''
    let l:bufdir = fnamemodify(bufname(l:bufnr), ':p:h')
    if '' != l:bufdir
      return l:bufnr
    endif
  endif

  let l:bufnr = s:bufnr
  if getbufvar(l:bufnr, '&buftype') ==# ''
    let l:bufdir = fnamemodify(bufname(l:bufnr), ':p:h')
    if '' != l:bufdir
      return l:bufnr
    endif
  endif

  return ''

endfunction

function! quickfilesearch2#QFSFileSearchInput()
  let l:filename = input('Enter filename:')
  if '' == l:filename
    return
  endif
  call quickfilesearch2#QFSFileSearch(l:filename)
endfunction


function! quickfilesearch2#QFSFileSearch(...)

  if 1 > a:0
    return
  endif
  let l:searchword = join(a:000, ' ')

  " get listfile path
  let l:bufnr = s:get_bufnr()
  if '' == l:bufnr
    return
  endif

  let s:find_mkfile = 0
  let s:lsfile_path = s:search_lsfile(fnamemodify(bufname(l:bufnr), ':p:h'))
  if '' == s:lsfile_path
    if l:bufnr != s:bufnr
      let s:find_mkfile = 0
      let s:lsfile_path = s:search_lsfile(fnamemodify(bufname(s:bufnr), ':p:h'))
    endif
    if '' == s:lsfile_path
      if 0 == s:find_mkfile
        call confirm('note: not found ['.g:qsf_lsfile.'] & ['.g:qsf_mkfile.']')
      else
        call confirm('info: end')
      endif
      return
    endif
  endif

  let s:bufnr = l:bufnr
  let l:lsfile_tmp = fnamemodify(s:lsfile_path.'.tmp', ':p')
  " echo l:lsfile_tmp

  "tmp作成
  call s:make_tmp(s:lsfile_path, l:lsfile_tmp, l:searchword)

  if !filereadable(l:lsfile_tmp)
    call confirm('error: could not open ['.l:lsfile_tmp.']')
    return
  endif

  "tmp表示
  call s:cgetfile(l:lsfile_tmp)

  "tmp削除
  call delete(l:lsfile_tmp)

  "Move the cursor to quickfix window after search
  if 0 == g:qsf_focus_quickfix
    wincmd w
  endif

endfunction

function! s:make_tmp(lsfile_path, lsfile_tmp, searchword)

  if 1 == s:is_win
    let l:grep_cmd = '!findstr /I'
  else
    let l:grep_cmd = '!\grep -G -i -s -e'
  endif
  let l:searchword = substitute(a:searchword, '\v([^\.])\*', '\1.\*', 'g')
  let l:searchword = substitute(l:searchword, '\v([^\\])\.([^\*])', '\1\\.\2', 'g')
  let l:searchword = substitute(l:searchword, '\v\s{1,}', '.*', 'g')
  let l:searchword = shellescape(l:searchword)
  let l:escaped_lsfile_path = shellescape(a:lsfile_path)
  let l:escaped_lsfile_tmp = shellescape(a:lsfile_tmp)
  let l:execute = l:grep_cmd.' '.l:searchword.' '.l:escaped_lsfile_path.' > '.l:escaped_lsfile_tmp
  silent execute '!\touch '.l:escaped_lsfile_tmp
  silent execute l:execute
  let s:searchword = l:searchword
endfunction

function! s:cgetfile(lsfile_tmp)

  "行数が多いとquickfixに読み込むのに時間がかかるため行数チェック
  silent execute 'tabe ' . a:lsfile_tmp
  let l:line = line('$')
  let l:fsize = getfsize(expand('%'))
  silent execute 'bd! ' . bufnr('%')

  "Not Found
  if 0 == l:fsize
    call confirm('note: not found ['.s:searchword.']')
    return
  endif

  "閾値より大きい場合はメッセージ表示で終わり
  if l:line > g:qsf_maxline
    call confirm('caution: search result('.l:line.' lines) exceeded '.g:qsf_maxline.' lines!')
    return
  endif

  "閾値より少ない場合はエラーファイルへ
  let l:bak_errorformat = &errorformat
  let &errorformat='%f'
  silent execute 'cgetfile ' . a:lsfile_tmp
  let &errorformat=l:bak_errorformat

  copen

endfunction

function! quickfilesearch2#QFSMakeList()

  " get listfile path
  let l:bufnr = s:get_bufnr()
  if '' == l:bufnr
    return
  endif

  let s:find_mkfile = 0
  let l:mkfile_dir = s:search_mkfile(fnamemodify(bufname(l:bufnr), ':p:h'))
  if '' != l:mkfile_dir
    let l:res = s:exec_make(l:mkfile_dir.s:ds)
    if 1 == l:res
      let s:find_mkfile = 0
      let l:mkfile_dir = ''
    elseif 2 == l:res
      return
    endif
  else
    if l:bufnr != s:bufnr
      let s:find_mkfile = 0
      let l:mkfile_dir = s:search_mkfile(fnamemodify(bufname(s:bufnr), ':p:h'))
      if '' != l:mkfile_dir
        let l:res = s:exec_make(l:mkfile_dir.s:ds)
        if 1 == l:res
          let s:find_mkfile = 0
          let l:mkfile_dir = ''
        elseif 2 == l:res
          return
        endif
      endif
    endif
  endif

  if '' == l:mkfile_dir
    if 0 == s:find_mkfile
      call confirm('note: not found ['.g:qsf_mkfile.']')
    else
      call confirm('note: search end')
    endif
    return
  endif

endfunction

function! s:exec_make(dir)

  let l:lsfile_path = fnamemodify(a:dir.g:qsf_lsfile, ':p')
  let l:mkfile_path = fnamemodify(a:dir.g:qsf_mkfile, ':p')

  if 1 == s:is_win
    let l:drive = a:dir[:stridx(a:dir, ':')]
    let l:execute = '!'.l:drive.' & cd '.shellescape(a:dir).' & '.shellescape(l:mkfile_path)
  else
    let l:execute = '!cd '.shellescape(a:dir).'; /bin/bash '.shellescape(l:mkfile_path)
  endif

  let l:conf = confirm('Execute? ['.l:execute.']', "Yyes\nNno")
  let s:qsf_ask_one_flg = 1
  if 1 != l:conf
    return 2
  endif

  call delete(l:lsfile_path)
  silent execute l:execute

  if !filereadable(l:lsfile_path)
    call confirm('error: could not create ['.l:lsfile_path.']')
    return 1
  endif

  call confirm('info: created ['.l:lsfile_path.']')
  return 0

endfunction

function! s:is_remote(path)
  let l:pt = '\v(ftp:\/\/.*|rcp:\/\/.*|ssh:\/\/.*|scp:\/\/.*|http:\/\/.*|file:\/\/.*|https:\/\/.*|dav:\/\/.*|davs:\/\/.*|rsync:\/\/.*|sftp:\/\/.*)'
  let l:match = matchstr(a:path, l:pt)
  if '' != l:match
    if 1 == s:debug
      let outputfile = "~/quickfilesearch2_is_remote.log"
      execute ":redir! >> " . outputfile
          silent! echon l:match . "\n"
      redir END
    endif
    return 1
  endif
  return 0
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

