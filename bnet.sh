#!/bin/sh

WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
WINEARCH=win64

install_bnet() {

rm -rf $WINEPREFIX

echo "Creating Wine prefix at $WINEPREFIX..."
wineboot --init

echo "Installing core fonts..."
winetricks -q arial tahoma

echo "Installing DXVK..."
winetricks -q dxvk

DOWNLOAD_DIR="$(mktemp -d)"
BNET_SETUP_EXE="$DOWNLOAD_DIR/BattleNet-Setup.exe"
BATTLENET_URL="https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP"

echo "Downloading Battle.net Launcher..."
mkdir -p "$DOWNLOAD_DIR"
curl -L "$BATTLENET_URL" -o "$BNET_SETUP_EXE"

echo "Setting Windows version to Windows 10..."
wine reg add "HKEY_CURRENT_USER\\Software\\Wine" /v Version /d win10 /f

echo "Enabling DXVA2 in Wine Staging..."
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\DXVA2" /v backend /d va /f

echo "Setting specific settings for BlizzardBrowser.exe..."
wine reg add "HKEY_CURRENT_USER\\Software\\Wine\\AppDefaults\\BlizzardBrowser.exe" /v version /t REG_SZ /d win7 /f

echo "Running Battle.net installer $BNET_SETUP_EXE ..."
wine64 "$BNET_SETUP_EXE"

echo "Installation complete. Close Battle.net after the installation finishes."
wineboot --kill

echo "Writing Battle.net configuration..."
BNET_CONFIG_DIR="$WINEPREFIX/drive_c/users/$USER/AppData/Roaming/Battle.net"

mkdir -p "$BNET_CONFIG_DIR"
cat > "$BNET_CONFIG_DIR/Battle.net.config" <<EOF
{
  "Client": {
    "GameLaunchWindowBehavior": "2",
    "GameSearch": {
      "BackgroundSearch": "true"
    },
    "HardwareAcceleration": "false",
    "Install": {
      "DownloadLimitNextPatchInBps": "0"
    },
    "Sound": {
      "Enabled": "false"
    },
    "Streaming": {
      "StreamingEnabled": "false"
    }
  },
  "Games": {
    "s2": {
      "AdditionalLaunchArguments": "-Displaymode 1"
    }
  }
}
EOF
}

if [ ! -d "$WINEPREFIX" ]; then
  install_bnet
fi

BNET_EXE="$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"

DXVK_HUD=compiler 
DXVK_STATE_CACHE_PATH="$WINEPREFIX" 
STAGING_SHARED_MEMORY=1 
__GL_SHADER_DISK_CACHE=1 
__GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1 
__GL_SHADER_DISK_CACHE_PATH="$WINEPREFIX" 

wine64 "$BNET_EXE"
