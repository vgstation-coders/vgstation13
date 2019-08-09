export MAPFILE_TG=tgstation.dmm
export MAPFILE_EFF=defficiency.dmm
export MAPFILE_MS=metaclub.dmm
export MAPFILE_PCK=packedstation.dmm
export MAPFILE_ROID=RoidStation.dmm
export MAPFILE_SNAXI=snaxi.dmm

java -jar MapPatcher.jar -clean ../maps/$MAPFILE_TG.backup ../maps/$MAPFILE_TG ../maps/$MAPFILE_TG
java -jar MapPatcher.jar -clean ../maps/$MAPFILE_EFF.backup ../maps/$MAPFILE_EFF ../maps/$MAPFILE_EFF
java -jar MapPatcher.jar -clean ../maps/$MAPFILE_MS.backup ../maps/$MAPFILE_MS ../maps/$MAPFILE_MS
java -jar MapPatcher.jar -clean ../maps/$MAPFILE_PCK.backup ../maps/$MAPFILE_PCK ../maps/$MAPFILE_PCK
java -jar MapPatcher.jar -clean ../maps/$MAPFILE_ROID.backup ../maps/$MAPFILE_ROID ../maps/$MAPFILE_ROID
java -jar MapPatcher.jar -clean ../maps/$MAPFILE_SNAXI.backup ../maps/$MAPFILE_SNAXI ../maps/$MAPFILE_SNAXI

read -n1 -r -p "Press any key to continue..." key
