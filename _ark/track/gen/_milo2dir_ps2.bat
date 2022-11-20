FOR /F "tokens=*" %%G IN ('dir /b *.milo_ps2') DO superfreq milo2dir "%%G" "unpack_ps2\%%~nG"
