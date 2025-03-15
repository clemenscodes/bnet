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
          mkdir -p "$DOWNLOAD_DIR"
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
    battlenet = pkgs.writeShellApplication {
      name = "battlenet";
      runtimeInputs = [
        pkgs.curl
        umu
      ];
      text = ''
        export BNET_EXE="$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"
        export WINEPREFIX=$HOME/.local/share/wineprefixes/bnet
        export WINEARCH=win64
        export GAMEID=umu-default
        export PROTON_VERB=runinprefix

        install_bnet() {
          DOWNLOAD_DIR="$(mktemp -d)"
          BNET_SETUP_EXE="$DOWNLOAD_DIR/BattleNet-Setup.exe"
          BATTLENET_URL="https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP"
          echo "Downloading Battle.net Launcher..."
          mkdir -p "$DOWNLOAD_DIR"
          curl -L "$BATTLENET_URL" -o "$BNET_SETUP_EXE"
          umu-run "$BNET_SETUP_EXE"
        }

        if [[ ! -d "$WINEPREFIX" || ! -f "$BNET_EXE" ]]; then
          install_bnet
        fi

        umu-run "$BNET_EXE"
      '';
    };
  in {
    packages = {
      ${system} = {
        inherit battlenet bonjour w3champions;
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
          ];
        };
      };
    };
  };
}
