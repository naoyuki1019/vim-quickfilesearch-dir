touch .lsfile
\find `pwd` -type d -name lib -prune -o -not -iwholename '*/.git/*' -type f \( -name \*.php -o -name \*.js -o -name \*.css \) -print > .lsfile

