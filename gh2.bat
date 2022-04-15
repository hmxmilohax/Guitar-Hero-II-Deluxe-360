del /f %~dp0\gen\main.hdr
del /f %~dp0\gen\main_0.ark
del /f %~dp0\gen\main_1.ark
arkhelper dir2ark %~dp0\gen %~dp0\build -e -s 4073741823
move %~dp0\build\main.hdr %~dp0\gen\main.hdr
move %~dp0\build\main_0.ark %~dp0\gen\main_0.ark
xenia_canary.exe default.xex
