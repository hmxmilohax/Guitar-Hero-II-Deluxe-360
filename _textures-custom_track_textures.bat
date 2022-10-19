cd "%~custom_track_textures"
FOR /F "tokens=*" %%G IN ('dir /b *.png') DO "%~dp0dependencies/superfreq.exe" png2tex "%~dp0custom_track_textures/%%G" "%~dp0_ark\track\custom_track_textures\gen\%%~nG_keep.png_xbox" --platform x360 --miloVersion 25
pause