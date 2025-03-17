#!/bin/sh

export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
export WINEARCH=win64
export W3C_EXE="$WINEPREFIX/drive_c/Program Files/W3Champions/W3Champions.exe"

install_w3c() {
  W3C_SETUP_URL="https://update-service.w3champions.com/api/launcher-e"
  DOWNLOAD_DIR="$(mktemp -d)"
  W3C_SETUP_MSI="$DOWNLOAD_DIR/w3c.msi"
  echo "Downloading W3Champions installer..."
  curl -L "$W3C_SETUP_URL" -o "$W3C_SETUP_MSI"
  wine "$W3C_SETUP_MSI"
}

if [ ! -e "$W3C_EXE" ]; then
  install_w3c
fi

wine "$W3C_EXE"
