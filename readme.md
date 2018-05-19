# vim-quickfilesearch2

quickfilesearch2 look for a file named .lsfile(g:qsf_lsfile) & .lsfile.sh(g:qsf_mkfile) in the directory of the opened file and in every parent directory.

```
/dir/subdir/.lsfile
/dir/.lsfile
/.lsfile
```

This plugin displays the search results of file from .lsfile into Quickfix

## How to use

- search file pt1

  :FS `filename`

- search file pt2

  :QFSFileSearch

  &nbsp;&nbsp;&nbsp;&nbsp;Enter filename:`filename`


- make list file

  :QFSMakeList

## Setting

### ~/.vimrc

```vim
let g:qsf_lsfile = '.lsfile' "default
let g:qsf_maxline = 200 "default
let g:qsf_focus_quickfix = 1 "move the cursor to quickfix after search
let g:qsf_mkfile = '.lsfile.bat' "default windows
let g:qsf_mkfile = '.lsfile.sh' "default linux

"noremap <C-F12> :<C-u>QFSFileSearch<CR>
```

### make .lsfile

#### sample linux osx

```shell
#find
\find `pwd` -type d -name lib -prune -o -not -iwholename '*/.git/*' -type f \( -name \*.php -o -name \*.js -o -name \*.css \) -print > .lsfile
```

#### sample windows

```bat
rem dir & findstr
rem dir /s /b /a-d * | findstr /i /v "\\\.git\\" > .lsfile
dir /s /b /a-d *.php *.tpl *.js *.css  > .lsfile
```

