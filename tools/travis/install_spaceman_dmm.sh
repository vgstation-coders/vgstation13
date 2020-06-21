#!/bin/bash
set -euo pipefail

wget -O ~/$1 "https://github.com/SpaceManiac/SpacemanDMM/releases/download/$SPACEMAN_DMM_GIT_TAG/$1"
chmod +x ~/$1
~/$1 --version
