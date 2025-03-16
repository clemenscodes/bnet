#!/bin/sh

export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
export WINEARCH=win64
export GAMEID=umu-default
export UMU_LOG=debug

install_w3c() {
  W3C_SETUP_URL="https://update-service.w3champions.com/api/launcher-e"
  DOWNLOAD_DIR="$(mktemp -d)"
  W3C_SETUP_MSI="$DOWNLOAD_DIR/w3c.msi"
  echo "Downloading W3Champions installer..."
  curl -L "$W3C_SETUP_URL" -o "$W3C_SETUP_MSI"
  umu-run "$W3C_SETUP_MSI"
}


install_webview2() {
  WEBVIEW2_SETUP_URL="https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/1016fd13-5855-47b6-bfb3-f218431cf784/Microsoft.WebView2.FixedVersionRuntime.134.0.3124.68.x64.cab"
  DOWNLOAD_DIR="$(mktemp -d)"
  WEBVIEW2_SETUP_CAB="$DOWNLOAD_DIR/webview2.cab"
  WEBVIEW2_SETUP_EXE="$DOWNLOAD_DIR/Microsoft.WebView2.FixedVersionRuntime.134.0.3124.68.x64/msedgewebview2.exe"
  echo "Downloading WebView2 installer..."
  curl -L "$WEBVIEW2_SETUP_URL" -o "$WEBVIEW2_SETUP_CAB"
  echo "Unpacking WebView2 cabinet files..."
  cabextract "$WEBVIEW2_SETUP_CAB" -d "$DOWNLOAD_DIR"
  umu-run winetricks --force vcrun2017
  umu-run winetricks --force corefonts
  umu-run winetricks --force vcrun2015
  umu-run "$WEBVIEW2_SETUP_EXE"
}

W3C_EXE="$WINEPREFIX/drive_c/Program Files/W3Champions/W3Champions.exe"

if [ ! -e "$W3C_EXE" ]; then
  install_w3c
fi

umu-run "$W3C_EXE"

