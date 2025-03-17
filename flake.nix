{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
        };
      };
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
    wine = inputs.nix-gaming.packages.${system}.wine-ge;
    battlenet = pkgs.writeShellApplication {
      name = "battlenet";
      runtimeInputs = [
        pkgs.curl
        pkgs.samba
        pkgs.winetricks
        wine
        umu
      ];
      text = ''
        export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
        export WINEARCH=win64
        export BNET_EXE="$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"
        export PATH="${wine}/bin:$PATH"

        install_bnet() {
          DOWNLOAD_DIR="$(mktemp -d)"
          BNET_SETUP_EXE="$DOWNLOAD_DIR/BattleNet-Setup.exe"
          BATTLENET_URL="https://downloader.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe"
          echo "Downloading Battle.net Launcher..."
          curl -L "$BATTLENET_URL" -o "$BNET_SETUP_EXE"
          umu-run winetricks dxvk
          umu-run "$BNET_SETUP_EXE"
        }

        if [[ ! -d "$WINEPREFIX" || ! -f "$BNET_EXE" ]]; then
          install_bnet
        fi

        umu-run "$BNET_EXE"
      '';
    };
    bonjour = pkgs.writeShellApplication {
      name = "bonjour";
      runtimeInputs = [
        wine
        umu
      ];
      text = ''
        export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
        export WINEARCH=win64

        wine stop 'Bonjour Service'
        wine start 'Bonjour Service'
      '';
    };
    w3champions-legacy = pkgs.writeShellApplication {
      name = "w3champions-legacy";
      runtimeInputs = [
        pkgs.curl
        wine
        umu
      ];
      text = ''
        export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
        export W3C_EXE="$WINEPREFIX/drive_c/users/$USER/AppData/Local/Programs/w3champions/w3champions.exe"
        export WINEARCH=win64
        export PATH="${wine}/bin:$PATH"

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
      '';
    };
    w3champions = pkgs.writeShellApplication {
      name = "w3champions";
      runtimeInputs = [
        pkgs.curl
        wine
        umu
      ];
      text = ''
        export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
        export W3C_EXE="$WINEPREFIX/drive_c/Program Files/W3Champions/W3Champions.exe"
        export WINEARCH=win64
        export PATH="${wine}/bin:$PATH"

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
      '';
    };
    webview2 = pkgs.writeShellApplication {
      name = "webview2";
      runtimeInputs = [
        pkgs.winetricks
        wine
        umu
      ];
      text = ''
        export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
        export WINEARCH=win64
        export PATH="${wine}/bin:$PATH"

        install_webview2() {
          WEBVIEW2_SETUP_EXE="${./assets/MicrosoftEdgeWebview2Setup.exe}"
          winetricks --force corefonts
          winetricks --force vcrun2017
          winetricks --force dotnet40
          wine "$WEBVIEW2_SETUP_EXE"
        }

        install_webview2
      '';
    };
  in {
    packages = {
      ${system} = {
        inherit battlenet bonjour w3champions w3champions-legacy webview2;
        default = self.packages.${system}.w3champions;
      };
    };
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = [
            battlenet
            bonjour
            w3champions
            w3champions-legacy
            webview2
          ];
          nativeBuildInputs = [
            pkgs.winetricks
            pkgs.samba
            wine
            umu
          ];
          shellHook = ''
            export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
            export WINEARCH=win64
            export PATH="${wine}/bin:$PATH"
            export BNET_EXE="$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"
            export W3C_EXE="$WINEPREFIX/drive_c/Program Files/W3Champions/W3Champions.exe"
            export W3C_LEGACY_EXE="$WINEPREFIX/drive_c/users/$USER/AppData/Local/Programs/w3champions/w3champions.exe"
            export APPDATA="$WINEPREFIX/drive_c/users/$USER/AppData"
            export APPDATA_LOCAL="$APPDATA/Local"
            export APPDATA_ROAMING="$APPDATA/Roaming"
            export W3C_APPDATA="$APPDATA_LOCAL/com.w3champions.client"
          '';
        };
      };
    };
  };
}
