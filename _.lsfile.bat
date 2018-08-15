rem dir & findstr
rem dir /s /b /a-d * | findstr /i /v "\\\.git\\" > .lsfile
dir /s /b /a-d *.php *.tpl *.css *.js  > .lsfile

