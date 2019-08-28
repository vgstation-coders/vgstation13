set MAPFILE_TG=tgstation.dmm
set MAPFILE_EFF=defficiency.dmm
set MAPFILE_MS=metaclub.dmm
set MAPFILE_PCK=packedstation.dmm
set MAPFILE_ROID=RoidStation.dmm
set MAPFILE_SNAXI=snaxi.dmm

java -jar MapPatcher.jar -clean ../maps/%MAPFILE_TG%.backup ../maps/%MAPFILE_TG% ../maps/%MAPFILE_TG%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_EFF%.backup ../maps/%MAPFILE_EFF% ../maps/%MAPFILE_EFF%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_MS%.backup ../maps/%MAPFILE_MS% ../maps/%MAPFILE_MS%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_PCK%.backup ../maps/%MAPFILE_PCK% ../maps/%MAPFILE_PCK%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_ROID%.backup ../maps/%MAPFILE_ROID% ../maps/%MAPFILE_ROID%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_SNAXI%.backup ../maps/%MAPFILE_SNAXI% ../maps/%MAPFILE_SNAXI%

pause
