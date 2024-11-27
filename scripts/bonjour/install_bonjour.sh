#!/bin/sh

export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
export WINEARCH=win64
export GAMEID=umu-default

PROGRAM_FILES="$WINEPREFIX/drive_c/Program Files"
BONJOUR="$PROGRAM_FILES/Bonjour"
BLIZZARD="$PROGRAM_FILES/Blizzard"
BLIZZARD_BONJOUR="$BLIZZARD/Bonjour Service"

install_bonjour() {
  BONJOUR_SETUP_EXE="./Bonjour64.msi"
  umu-run "$BONJOUR_SETUP_EXE"
}

if [ ! -d "$BONJOUR" ]; then
  install_bonjour
fi

ln -s "$BONJOUR" "$BLIZZARD_BONJOUR"
