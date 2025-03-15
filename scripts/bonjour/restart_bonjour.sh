#!/bin/sh

export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
export WINEARCH=win64
export GAMEID=umu-default
export PROTON_VERB=runinprefix

umu-run $WINEPREFIX/drive_c/windows/system32/net.exe stop 'Bonjour Service'
umu-run $WINEPREFIX/drive_c/windows/system32/net.exe start 'Bonjour Service'
