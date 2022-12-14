rem git pull https://github.com/hmxmilohax/Guitar-Hero-II-Deluxe-360 main
call "%~dp0_album_art.bat"
"%~dp0dependencies/arkhelper" dir2ark "%~dp0\_ark" "%~dp0\_build\Xbox\gen" -e -s 4073741823
pause