#!/bin/sh

export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
export WINEARCH=win64

wine net stop 'Bonjour Service'
wine net start 'Bonjour Service'
