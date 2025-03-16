{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    umu = {
      url = "github:Open-Wine-Components/umu-launcher?dir=packaging/nix";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
    };
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    umu = inputs.umu.packages.${system}.default.override {
      extraPkgs = pkgs: [];
      extraLibraries = pkgs: [];
      withMultiArch = true;
      withTruststore = true;
      withDeltaUpdates = true;
    };
    battlenet = pkgs.writeShellApplication {
      name = "battlenet";
      runtimeInputs = [
        pkgs.curl
        pkgs.samba
        pkgs.winetricks
        umu
      ];
      text = ''
        export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
        export WINEARCH=win64
        export GAMEID=umu-default
        export BNET_EXE="$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"

        install_bnet() {
          DOWNLOAD_DIR="$(mktemp -d)"
          BNET_SETUP_EXE="$DOWNLOAD_DIR/BattleNet-Setup.exe"
          BATTLENET_URL="https://downloader.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe"
          echo "Downloading Battle.net Launcher..."
          curl -L "$BATTLENET_URL" -o "$BNET_SETUP_EXE"
          umu-run "$BNET_SETUP_EXE"
        }

        if [[ ! -d "$WINEPREFIX" || ! -f "$BNET_EXE" ]]; then
          install_bnet
        fi

        PROTON_VERB=runinprefix umu-run "$BNET_EXE"
      '';
    };
    bonjour = pkgs.writeShellApplication {
      name = "bonjour";
      runtimeInputs = [
        umu
      ];
      text = ''
        export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
        export WINEARCH=win64
        export PROTON_VERB=runinprefix

        umu-run "$WINEPREFIX/drive_c/windows/system32/net.exe" stop 'Bonjour Service'
        umu-run "$WINEPREFIX/drive_c/windows/system32/net.exe" start 'Bonjour Service'
      '';
    };
    w3champions = pkgs.writeShellApplication {
      name = "w3champions";
      runtimeInputs = [
        pkgs.curl
        umu
      ];
      text = ''
        export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
        export WINEARCH=win64
        export GAMEID=umu-default

        install_w3c() {
          W3C_SETUP_URL="https://update-service.w3champions.com/api/launcher/win"
          DOWNLOAD_DIR="$(mktemp -d)"
          W3C_SETUP_EXE="$DOWNLOAD_DIR/w3c-setup.exe"
          echo "Downloading W3Champions installer..."
          curl -L "$W3C_SETUP_URL" -o "$W3C_SETUP_EXE"
          umu-run "$W3C_SETUP_EXE"
        }

        W3C_EXE="$WINEPREFIX/drive_c/users/$USER/AppData/Local/Programs/w3champions/w3champions.exe"

        if [ ! -e "$W3C_EXE" ]; then
          install_w3c
        fi

        umu-run "$W3C_EXE"
      '';
    };
    webview2-w3champions = pkgs.writeShellApplication {
      name = "webview2-w3champions";
      runtimeInputs = [
        pkgs.curl
        pkgs.cabextract
        umu
      ];
      text = ''
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
      '';
    };
  in {
    packages = {
      ${system} = {
        inherit battlenet bonjour w3champions webview2-w3champions;
        default = self.packages.${system}.battlenet;
      };
    };
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = [
            battlenet
            bonjour
            w3champions
            webview2-w3champions
          ];
        };
      };
    };
  };
}
