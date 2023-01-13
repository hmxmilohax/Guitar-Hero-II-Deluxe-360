set FAILED_ARK_BUILD=0
git pull https://github.com/hmxmilohax/Guitar-Hero-II-Deluxe-360 main
@echo off
echo:
echo:Copying detected album art files to their proper place. Building GHIIDX ARK soon.
call "%~dp0_album_art.bat" >nul 2>&1
echo:
echo:Temporarily moving PS2 files out of the ark path to reduce final ARK size
@%SystemRoot%\System32\robocopy.exe "%~dp0\_ark" "%~dp0_temp\_ark" *.milo_ps2 /S /MOVE /XD "%~dp0_temp\_ark" /NDL /NFL /NJH /NJS /R:0 >nul
@%SystemRoot%\System32\robocopy.exe "%~dp0\_ark" "%~dp0_temp\_ark" *.png_ps2 /S /MOVE /XD "%~dp0_temp\_ark" /NDL /NFL /NJH /NJS /R:0 >nul
@%SystemRoot%\System32\robocopy.exe "%~dp0\_ark" "%~dp0_temp\_ark" *.bmp_ps2 /S /MOVE /XD "%~dp0_temp\_ark" /NDL /NFL /NJH /NJS /R:0 >nul
@%SystemRoot%\System32\robocopy.exe "%~dp0\_ark" "%~dp0_temp\_ark" *.vgs /S /MOVE /XD "%~dp0_temp\_ark" /NDL /NFL /NJH /NJS /R:0 >nul
echo:
echo:Building Xbox ARK
"%~dp0dependencies/arkhelper" dir2ark "%~dp0\_ark" "%~dp0\_build\Xbox\gen" -e -s 4073741823 >nul
if %errorlevel% neq 0 (set FAILED_ARK_BUILD=1)
echo:
echo:Writing init files
call _init-dta2b >nul 2>&1
if %errorlevel% neq 0 (set FAILED_ARK_BUILD=1)
echo:
echo:Moving back PS2 files
@%SystemRoot%\System32\robocopy.exe "%~dp0_temp\_ark" "%~dp0\_ark" *.milo_ps2 /S /MOVE /XD "%~dp0_ark" /NDL /NFL /NJH /NJS /R:0 >nul
@%SystemRoot%\System32\robocopy.exe "%~dp0_temp\_ark" "%~dp0\_ark" *.png_ps2 /S /MOVE /XD "%~dp0_ark" /NDL /NFL /NJH /NJS /R:0 >nul
@%SystemRoot%\System32\robocopy.exe "%~dp0_temp\_ark" "%~dp0\_ark" *.bmp_ps2 /S /MOVE /XD "%~dp0_ark" /NDL /NFL /NJH /NJS /R:0 >nul
@%SystemRoot%\System32\robocopy.exe "%~dp0_temp\_ark" "%~dp0\_ark" *.vgs /S /MOVE /XD "%~dp0_ark" /NDL /NFL /NJH /NJS /R:0 >nul
rd _temp
echo:
if %FAILED_ARK_BUILD% neq 1 (echo:Successfully built Guitar Hero II Deluxe ARK.)
if %FAILED_ARK_BUILD% neq 1 (echo:)
if %FAILED_ARK_BUILD% neq 0 (echo:Error building ARK or init files. Check your modifications or run _git_reset.bat to rebase your repo.)
if %FAILED_ARK_BUILD% neq 1 (echo:Launching Xenia & START "" "%~dp0\_xenia\xenia_canary" "%~dp0\_build\xbox\default.xex")
echo:
if %FAILED_ARK_BUILD% neq 0 (pause)