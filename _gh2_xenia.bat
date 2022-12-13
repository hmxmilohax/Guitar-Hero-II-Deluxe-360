git pull https://github.com/hmxmilohax/Guitar-Hero-II-Deluxe-360 main
for /f "tokens=*" %%D in ('dir /b /s /a:d "%~dp0\content\*"') do (for /f "delims=" %%A in ('dir /s /b "%%D\gen\*.bmp_xbox"') do mkdir "%~dp0_build\Xbox\gen\album_art\%%~nD" && mkdir "%~dp0_build\Xbox\gen\album_art\%%~nD\gen" && xcopy "%%D\gen\*.bmp_xbox" "%~dp0_build\Xbox\gen\album_art\%%~nD\gen" /Y)
for /f "tokens=*" %%D in ('dir /b /s /a:d "%~dp0\content\*"') do (for /f "delims=" %%A in ('dir /s /b "%%D\*.mid"') do mkdir "%~dp0_build\Xbox\gen\album_art\%%~nD" && mkdir "%~dp0_build\Xbox\gen\album_art\%%~nD\gen" && copy /b "_ark\ui\image\ng\gen\photo_random0_keep.bmp_xbox" "%~dp0_build\Xbox\gen\album_art\%%~nD\gen\%%~nD.bmp_xbox" /N)
"%~dp0dependencies/arkhelper" dir2ark "%~dp0\_ark" "%~dp0\_build\Xbox\gen" -e -s 4073741823
"%~dp0xenia_canary.exe" "%~dp0\_build\Xbox\default.xex"
pause