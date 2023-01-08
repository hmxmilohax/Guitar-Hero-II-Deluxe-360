FOR /F "tokens=*" %%G IN ('dir /b poorspy_viewer.milo_xbox') DO superfreq milo2dir "%%G" "unpack_xbox\%%~nG" --convertTextures --preset gh2_x360 --bigEndian
