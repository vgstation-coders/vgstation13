#!/bin/bash
set -e
if [ -e "$HOME/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}/byond/bin/DreamMaker" ];
then
  echo "Using cached directory."
else
  echo "Setting up BYOND."
  mkdir -p "$HOME/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}"
  cd "$HOME/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}"
  curl "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" -o byond.zip
  unzip -o byond.zip
  cd byond
  make here
  if [ ! -f "$HOME/BYOND-${BYOND_MAJOR}.${BYOND_MINOR}/byond/bin/DreamMaker" ]
  then
    echo "!!!!Couldn't find Dream Maker even after building, something is seriously wrong!!!!!"
    exit 3
  else
    echo "DreamMaker exists, we built correctly, hooray"
  fi
fi
