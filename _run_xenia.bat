@echo OFF
IF EXIST ".git\refs\heads\main" (
set /p localcommit=<.git\refs\heads\main
)
IF EXIST ".git\refs\heads\master" (
set /p localcommit=<.git\refs\heads\master
)
FOR /F "tokens=* USEBACKQ" %%F IN (`git rev-parse HEAD`) DO (
SET origincommit=%%F
)
echo:local commit = %localcommit% / latest commit = %origincommit%
IF %localcommit% == %origincommit% (
IF NOT EXIST "%~dp0_build/Xbox/gen/main_0.ark" (
echo:ARK not found, building
call _build_xenia.bat
) ELSE (
call _init-dta2b >nul 2>&1
START "" "%~dp0_xenia\xenia_canary" "%~dp0_build\Xbox\default.xex"
)
) ELSE (
exho:Fetching latest updates and building ARK
call _build_xenia.bat
)