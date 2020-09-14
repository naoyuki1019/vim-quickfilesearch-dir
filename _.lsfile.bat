rem dir & findstr
rem dir /s /b /a-d * | findstr /i /v "\\\.git\\" > .lsfile
type Nul > .lsfile
dir /s /b /a-d *.php *.tpl *.css *.js  > .lsfile

