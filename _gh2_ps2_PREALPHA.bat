git pull https://github.com/hmxmilohax/Guitar-Hero-II-Deluxe-360 main
copy "%~dp0\theme\init_ui_theme.dta" "%~dp0\_ark\ui\"
copy "%~dp0\theme\init_track_theme.dta" "%~dp0\_ark\ui\"
"%~dp0dependencies/arkhelper" dir2ark "%~dp0\_ark" "%~dp0\_build\PS2\GEN" -n "MAIN" -s 4073741823
del "%~dp0\_ark\ui\init_ui_theme.dta"
del "%~dp0\_ark\ui\init_track_theme.dta"
pause