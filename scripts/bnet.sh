#!/bin/sh

export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
export WINEARCH=win64
export BNET_EXE="$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"

install_bnet() {
  DOWNLOAD_DIR="$(mktemp -d)"
  BNET_SETUP_EXE="$DOWNLOAD_DIR/BattleNet-Setup.exe"
  BATTLENET_URL="https://downloader.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe"
  echo "Downloading Battle.net Launcher..."
  curl -L "$BATTLENET_URL" -o "$BNET_SETUP_EXE"
  wine "$BNET_SETUP_EXE"
}

if [ ! -d "$WINEPREFIX" ]; then
  install_bnet
fi

wine "$BNET_EXE"
