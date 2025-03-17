#!/bin/sh

export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
export WINEARCH=win64

install_webview2() {
  WEBVIEW2_SETUP_EXE="../assets/MicrosoftEdgeWebview2Setup.exe"
  winetricks --force vcrun2017
  winetricks --force corefonts
  winetricks --force vcrun2015
  wine "$WEBVIEW2_SETUP_EXE"
}

install_webview2
