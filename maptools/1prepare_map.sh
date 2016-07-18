export MAPFILE_EFF=defficiency.dmm
export MAPFILE_TAX=taxistation.dmm
export MAPFILE_MS=metaclub.dmm
export MAPFILE_MIN=ministation.dmm

cd ../maps

cp $MAPFILE_EFF $MAPFILE_EFF.backup
cp $MAPFILE_TAX $MAPFILE_TAX.backup
cp $MAPFILE_MS $MAPFILE_MS.backup
cp $MAPFILE_MIN $MAPFILE_MIN.backup
