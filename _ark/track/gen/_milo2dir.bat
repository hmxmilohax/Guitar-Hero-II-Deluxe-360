FOR /F "tokens=*" %%G IN ('dir /b *.milo_xbox') DO superfreq milo2dir "%%G" "unpack\%%~nG" --preset gh2_x360 --bigEndian --convertTextures
