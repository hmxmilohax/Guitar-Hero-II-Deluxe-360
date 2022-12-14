git pull https://github.com/hmxmilohax/Guitar-Hero-II-Deluxe-360 main
@echo off
echo:
echo:Copying detected album art files to their proper place.
echo:To add your own, place extracted LIVE files from your packs to \content\415607E7\00000002.
echo:Building GHIIDX ARK soon.
call "%~dp0_album_art.bat" >nul 2>&1
@echo on
"%~dp0dependencies/arkhelper" dir2ark "%~dp0\_ark" "%~dp0\_build\Xbox\gen" -e -s 4073741823
pause