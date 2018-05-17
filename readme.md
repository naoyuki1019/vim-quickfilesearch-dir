# vim-quickfilesearch2

quickfilesearch2 plugins look for a file named ".lsfile" in the directory of the opened file and in every parent directory.
<br>
*note: windows needs cygwin to use grep

## setting ~/.vimrc

```
let g:qsf_lsfile = '.lsfile' "default
let g:qsf_maxline = 200 "default
let g:qsf_focus_quickfix = 0 "1:Move the cursor to "quickfix window" after search

```

## make .lsfile sample

```
#find
find `pwd` -type d -name lib -prune -o -type f \( -name \*.php -o -name \*.js -o -name \*.css \) -print > .lsfile

rem win
dir /s /b *.php *.tpl *.css *.js *.css > .lsfile
```

