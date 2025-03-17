#!/bin/sh

export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
export W3C_EXE="$WINEPREFIX/drive_c/users/$USER/AppData/Local/Programs/w3champions/w3champions.exe"
export WINEARCH=win64

install_w3c() {
  W3C_SETUP_URL="https://update-service.w3champions.com/api/launcher/win"
  DOWNLOAD_DIR="$(mktemp -d)"
  W3C_SETUP_EXE="$DOWNLOAD_DIR/w3c-setup.exe"
  echo "Downloading W3Champions installer..."
  curl -L "$W3C_SETUP_URL" -o "$W3C_SETUP_EXE"
  wine "$W3C_SETUP_EXE"
}


if [ ! -e "$W3C_EXE" ]; then
  install_w3c
fi

wine "$W3C_EXE"
