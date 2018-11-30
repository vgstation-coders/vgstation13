set MAPFILE_TG=tgstation.dmm
set MAPFILE_EFF=defficiency.dmm
set MAPFILE_MS=metaclub.dmm
set MAPFILE_PCK=packedstation.dmm
set MAPFILE_BAG=bagelstation.dmm
set MAPFILE_ROID=RoidStation.dmm

java -jar MapPatcher.jar -clean ../maps/%MAPFILE_TG%.backup ../maps/%MAPFILE_TG% ../maps/%MAPFILE_TG%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_EFF%.backup ../maps/%MAPFILE_EFF% ../maps/%MAPFILE_EFF%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_MS%.backup ../maps/%MAPFILE_MS% ../maps/%MAPFILE_MS%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_PCK%.backup ../maps/%MAPFILE_PCK% ../maps/%MAPFILE_PCK%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_BAG%.backup ../maps/%MAPFILE_BAG% ../maps/%MAPFILE_BAG%
java -jar MapPatcher.jar -clean ../maps/%MAPFILE_ROID%.backup ../maps/%MAPFILE_ROID% ../maps/%MAPFILE_ROID%

pause
