#!/bin/sh

export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
export WINEARCH=win64
export GAMEID=umu-default

PROTON_VERB=runinprefix net stop 'Bonjour Service'
PROTON_VERB=runinprefix net start 'Bonjour Service'
