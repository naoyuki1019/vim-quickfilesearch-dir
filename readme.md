# vim-quickfilesearch2

quickfilesearch2 look for a file named .lsfile(default) in the directory of the opened file and in every parent directory.

```
/dir/subdir/.lsfile
/dev/.lsfile
/.lsfile
```

This plugin displays the search results of file from .lsfile (default) into Quickfix
<br>
*note: windows needs cygwin to use grep

## How to use

:FS `filename` <br>

:QFSFileSearch<br>
&nbsp;&nbsp;Enter filename:`filename`

## Setting

### ~/.vimrc

```vim
let g:qsf_lsfile = '.lsfile' "default
let g:qsf_maxline = 200 "default
let g:qsf_focus_quickfix = 1 "move the cursor to quickfix after search

noremap <C-F12> :<C-u>QFSFileSearch<CR>
```

### make .lsfile

#### linux osx

```shell
#find
find `pwd` -type d -name lib -prune -o -type f \( -name \*.php -o -name \*.js -o -name \*.css \) -print > .lsfile
```

#### windows

```bat
dir /s /b *.php *.tpl *.css *.js *.css > .lsfile
```

