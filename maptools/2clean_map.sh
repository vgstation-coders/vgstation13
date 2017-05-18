export MAPFILE_TG=tgstation.dmm
export MAPFILE_EFF=defficiency.dmm
export MAPFILE_TAX=taxistation.dmm
export MAPFILE_MS=metaclub.dmm
export MAPFILE_MIN=ministation.dmm
export MAPFILE_BAG=bagelstation.dmm

java -jar MapPatcher.jar -clean ../maps/$MAPFILE_TG.backup ../maps/$MAPFILE_TG ../maps/$MAPFILE_TG
java -jar MapPatcher.jar -clean ../maps/$MAPFILE_EFF.backup ../maps/$MAPFILE_EFF ../maps/$MAPFILE_EFF
java -jar MapPatcher.jar -clean ../maps/$MAPFILE_TAX.backup ../maps/$MAPFILE_TAX ../maps/$MAPFILE_TAX
java -jar MapPatcher.jar -clean ../maps/$MAPFILE_MS.backup ../maps/$MAPFILE_MS ../maps/$MAPFILE_MS
java -jar MapPatcher.jar -clean ../maps/$MAPFILE_MIN.backup ../maps/$MAPFILE_MIN ../maps/$MAPFILE_MIN
java -jar MapPatcher.jar -clean ../maps/$MAPFILE_BAG.backup ../maps/$MAPFILE_BAG ../maps/$MAPFILE_BAG

read -n1 -r -p "Press any key to continue..." key
