set MAPFILE_TG=tgstation.dmm
set MAPFILE_EFF=defficiency.dmm
set MAPFILE_MS=metaclub.dmm
set MAPFILE_PCK=packedstation.dmm
set MAPFILE_BAG=bagelstation.dmm
set MAPFILE_ROID=RoidStation.dmm

cd ../maps
copy %MAPFILE_TG% %MAPFILE_TG%.backup
copy %MAPFILE_EFF% %MAPFILE_EFF%.backup
copy %MAPFILE_MS% %MAPFILE_MS%.backup
copy %MAPFILE_PCK% %MAPFILE_PCK%.backup
copy %MAPFILE_BAG% %MAPFILE_BAG%.backup
copy %MAPFILE_ROID% %MAPFILE_ROID%.backup

pause
