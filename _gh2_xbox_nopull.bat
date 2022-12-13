rem git pull https://github.com/hmxmilohax/Guitar-Hero-II-Deluxe-360 main
for /f "tokens=*" %%D in ('dir /b /s /a:d "%~dp0\content\*"') do (for /f "delims=" %%A in ('dir /s /b "%%D\gen\*.bmp_xbox"') do mkdir "%~dp0_build\Xbox\gen\album_art\%%~nD" && mkdir "%~dp0_build\Xbox\gen\album_art\%%~nD\gen" && xcopy "%%D\gen\*.bmp_xbox" "%~dp0_build\Xbox\gen\album_art\%%~nD\gen" /Y)
"%~dp0dependencies/arkhelper" dir2ark "%~dp0\_ark" "%~dp0\_build\Xbox\gen" -e -s 4073741823
pause