del /f %~dp0\highways\highways.dta
cd %~dp0\highways
forfiles /s /m *.* /C "cmd /e:on /v:on /c set \"Phile=@file\" & if @ISDIR==FALSE ren @file !Phile: =_!"
forfiles /s /C "cmd /e:on /v:on /c set \"Phile=@file\" & if @ISDIR==TRUE ren @file !Phile: =_!"
@echo #define HIGHWAY_OBJECTS>> highways.dta
@echo ((>> highways.dta
for %%i in (*.png) do @echo %%~ni>> highways.dta
for %%i in (*.jpg) do @echo %%~ni>> highways.dta
@echo ))>> highways.dta
mv %~dp0\highways\highways.dta %~dp0_ark\ui\highways.dta