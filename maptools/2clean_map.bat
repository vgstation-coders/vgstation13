set MAPFILE_TG=tgstation.dmm
set MAPFILE_EFF=defficiency.dmm
set MAPFILE_TAX=taxistation.dmm
set MAPFILE_MS=metaclub.dmm

java -jar MapPatcher.jar -clean ../maps/%MAPFILE_TG%.backup ../maps/%MAPFILE_TG% ../maps/%MAPFILE_TG%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_EFF%.backup ../maps/%MAPFILE_EFF% ../maps/%MAPFILE_EFF%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_TAX%.backup ../maps/%MAPFILE_TAX% ../maps/%MAPFILE_TAX%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_MS%.backup ../maps/%MAPFILE_MS% ../maps/%MAPFILE_MS%

pause
