set MAPFILE_TG=tgstation.dmm
set MAPFILE_EFF=defficiency.dmm
set MAPFILE_TAX=taxistation.dmm
set MAPFILE_MS=metaclub.dmm

cd ../maps
copy %MAPFILE_TG% %MAPFILE_TG%.backup
copy %MAPFILE_EFF% %MAPFILE_EFF%.backup
copy %MAPFILE_TAX% %MAPFILE_TAX%.backup
copy %MAPFILE_MS% %MAPFILE_MS%.backup

pause
