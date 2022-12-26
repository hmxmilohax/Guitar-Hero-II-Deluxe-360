"%~dp0dependencies/dtab" -b "%~dp0\_theme\init_track_theme.dta" "%~dp0\_theme\init_track_theme.dtb"
"%~dp0dependencies/dtab" -b "%~dp0\_theme\init_ui_theme.dta" "%~dp0\_theme\init_ui_theme.dtb"
"%~dp0dependencies/dtab" -e "%~dp0\_theme\init_track_theme.dtb" "%~dp0\_build\Xbox\gen\init_track_theme.dtb"
"%~dp0dependencies/dtab" -e "%~dp0\_theme\init_ui_theme.dtb" "%~dp0\_build\Xbox\gen\init_ui_theme.dtb"
del "%~dp0\_theme\init_ui_theme.dtb"
del "%~dp0\_theme\init_track_theme.dtb"
pause