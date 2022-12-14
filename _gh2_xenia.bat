git pull https://github.com/hmxmilohax/Guitar-Hero-II-Deluxe-360 main
@echo off
echo:
echo:Copying detected album art files to their proper place. Building GHIIDX ARK soon.
call "%~dp0_album_art.bat" >nul 2>&1
@echo on
"%~dp0dependencies/arkhelper" dir2ark "%~dp0\_ark" "%~dp0\_build\Xbox\gen" -e -s 4073741823
"%~dp0xenia_canary.exe" "%~dp0\_build\Xbox\default.xex"
pause