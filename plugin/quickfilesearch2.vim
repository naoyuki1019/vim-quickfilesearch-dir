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


if !exists('g:qsf_lsfile')
  let g:qsf_lsfile = '.lsfile'
endif

if !exists('g:qsf_maxline')
  let g:qsf_maxline = 200
endif

"Move the cursor to quickfix window after search
if !exists('g:qsf_focus_quickfix')
  let g:qsf_focus_quickfix = 1
endif

"mkfile ***.sh ***.bat
if !exists('g:qsf_mkfile')
  let g:qsf_mkfile = 'make_lsfile.sh'
endif

let s:dir = ''
let s:bufnr = ''
let s:searchword = ''

command! -nargs=* FS call quickfilesearch2#QFSFileSearch(<f-args>)
command! QFSFileSearch2 call quickfilesearch2#QFSFileSearchInput()
command! QFSMakeListFile call quickfilesearch2#QFSMakeListFile()


function! s:get_filedir(dir, fname)

  let l:lsfile_path = fnamemodify(a:dir.'/'.a:fname, ':p')

  if filereadable(l:lsfile_path)
    if has('win32')
      return a:dir.'\'
    else
      return a:dir.'/'
    endif
  endif

  let l:dir = fnamemodify(a:dir.'/../', ':p:h')

  if s:dir == l:dir
    " echo 'windows root ' . s:dir
    return ''
  endif

  if '/' == l:dir
    " echo 'root directory / '
    return ''
  endif

  let s:dir = l:dir

  return s:get_filedir(l:dir, a:fname)

endfunction

function! s:getbufnr()

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

  " get listfile path
  let l:bufnr = s:getbufnr()
  if '' == l:bufnr
    return
  endif

  let s:dir = ''
  let l:filedir = s:get_filedir(fnamemodify(bufname(l:bufnr), ':p:h'), g:qsf_lsfile)
  if '' == l:filedir
    let s:dir = ''
    let l:filedir = s:get_filedir(fnamemodify(bufname(s:bufnr), ':p:h'), g:qsf_lsfile)
    if '' == l:filedir
      let l:conf = confirm('note: not found ['.g:qsf_lsfile.']')
      let l:filedir = quickfilesearch2#QFSMakeListFile()
      if '' == l:filedir
        return
      endif
    endif
  endif

  let s:bufnr = l:bufnr
  let l:lsfile_path = fnamemodify(l:filedir.g:qsf_lsfile, ':p')
  let l:lsfile_tmp = fnamemodify(l:lsfile_path.'.tmp', ':p')
  " echo l:lsfile_tmp

  "引数を空白で連結
  let l:searchword = ''
  for l:s in a:000
    let l:searchword .= l:s . ' '
  endfor
  let l:searchword = l:searchword[0:strlen(l:searchword) - 2]
  " echo l:searchword

  "tmp作成
  call s:make_tmp(l:lsfile_path, l:lsfile_tmp, l:searchword)

  if !filereadable(l:lsfile_tmp)
    let l:conf = confirm('error: cannot open ['.l:lsfile_tmp.']')
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

  if has('win32')
    let l:grep_cmd = '!findstr'
  else
    let l:grep_cmd = '!\grep -G -i -s -e'
  endif
  let l:searchword = substitute(a:searchword, '\([^\.]\)\*', '\1.\*', 'g')
  let l:searchword = substitute(l:searchword, ' ', '.*', 'g')
  let l:searchword = shellescape(l:searchword)
  let l:escaped_lsfile_path = shellescape(a:lsfile_path)
  let l:escaped_lsfile_tmp = shellescape(a:lsfile_tmp)
  let l:execute = l:grep_cmd.' '.l:searchword.' '.l:escaped_lsfile_path.' > '.l:escaped_lsfile_tmp
  " let l:conf = confirm('debug: '.l:execute)
  silent execute '!\touch '.l:escaped_lsfile_tmp
  silent execute l:execute
  let s:searchword = l:searchword
endfunction

function! s:cgetfile(lsfile_tmp)

  "行数が多いとquickfixに読み込むのに時間がかかるため行数チェック
  execute 'tabe ' . a:lsfile_tmp
  let l:line = line('$')
  let l:fsize = getfsize(expand('%'))
  execute 'bd! ' . bufnr('%')

  "Not Found
  if 0 == l:fsize
    let l:conf = confirm('note: not found ['.s:searchword.']')
    return
  endif

  "閾値より大きい場合はメッセージ表示で終わり
  if l:line > g:qsf_maxline
    let l:conf = confirm('caution: search result('.l:line.' lines) exceeded '.g:qsf_maxline.' lines!')
    return
  endif

  "閾値より少ない場合はエラーファイルへ
  let l:bak_errorformat = &errorformat
  let &errorformat='%f'
  execute 'cgetfile ' . a:lsfile_tmp
  let &errorformat=l:bak_errorformat

  copen

endfunction

function! quickfilesearch2#QFSMakeListFile()

  " get listfile path
  let l:bufnr = s:getbufnr()
  if '' == l:bufnr
    return ''
  endif

  let s:dir = ''
  let l:filedir = s:get_filedir(fnamemodify(bufname(l:bufnr), ':p:h'), g:qsf_mkfile)
  if '' == l:filedir
    let s:dir = ''
    let l:filedir = s:get_filedir(fnamemodify(bufname(s:bufnr), ':p:h'), g:qsf_mkfile)
    if '' == l:filedir
      let l:conf = confirm('note: not found ['.g:qsf_mkfile.']')
      return ''
    endif
  endif

  let l:lsfile_path = fnamemodify(l:filedir.g:qsf_lsfile, ':p')
  let l:mkfile_path = fnamemodify(l:filedir.g:qsf_mkfile, ':p')

  if has('win32')
    let l:drive = l:filedir[:stridx(l:filedir, ':')]
    let l:execute = '!'.l:drive.' & cd '.shellescape(l:filedir).' & '.shellescape(l:mkfile_path)
  else
    let l:execute = '!cd '.shellescape(l:filedir).'; /bin/bash '.shellescape(l:mkfile_path)
  endif

  let l:conf = confirm('execute? ['.l:execute.']', "Yyes\nNno")
  if 1 != l:conf
    return ''
  endif

  call delete(l:lsfile_path)
  silent execute l:execute

  if !filereadable(l:lsfile_path)
    let l:conf = confirm('error: could not create ['.l:lsfile_path.']')
    return ''
  endif

  let l:conf = confirm('info: created ['.l:lsfile_path.']')
  return l:filedir

endfunction


let &cpo = s:save_cpo
unlet s:save_cpo

