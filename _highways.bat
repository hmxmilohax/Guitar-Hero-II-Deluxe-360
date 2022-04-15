del /f %~dp0highways\highways.dta
cd %~dp0/highways
forfiles /s /m *.* /C "cmd /e:on /v:on /c set \"Phile=@file\" & if @ISDIR==FALSE ren @file !Phile: =_!"
forfiles /s /C "cmd /e:on /v:on /c set \"Phile=@file\" & if @ISDIR==TRUE ren @file !Phile: =_!"
for %%i in (*.bmp) do @echo "%%~ni">> highways.dta
for %%i in (*.png) do @echo "%%~ni">> highways.dta
for %%i in (*.jpg) do @echo "%%~ni">> highways.dta
mv %~dp0\highways\highways.dta %~dp0_ark\track\surfaces\highways.dta
FOR /F "tokens=*" %%G IN ('dir /b *.jpg') DO superfreq png2tex "%%G" "%~dp0\_ark\track\surfaces\gen\%%~nG_keep.bmp_xbox" --miloVersion 25 --preset gh2_x360
FOR /F "tokens=*" %%G IN ('dir /b *.png') DO superfreq png2tex "%%G" "%~dp0\_ark\track\surfaces\gen\%%~nG_keep.bmp_xbox" --miloVersion 25 --preset gh2_x360
FOR /F "tokens=*" %%G IN ('dir /b *.bmp') DO superfreq png2tex "%%G" "%~dp0\_ark\track\surfaces\gen\%%~nG_keep.bmp_xbox" --miloVersion 25 --preset gh2_x360