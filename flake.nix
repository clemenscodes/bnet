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

        install_bnet() {
          DOWNLOAD_DIR="$(mktemp -d)"
          BNET_SETUP_EXE="$DOWNLOAD_DIR/BattleNet-Setup.exe"
          BATTLENET_URL="https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP"
          echo "Downloading Battle.net Launcher..."
          mkdir -p "$DOWNLOAD_DIR"
          ${pkgs.curl}/bin/curl -L "$BATTLENET_URL" -o "$BNET_SETUP_EXE"
          umu-run "$BNET_SETUP_EXE"
        }

        if [ ! -d "$WINEPREFIX" ]; then
          install_bnet
        fi

        BNET_EXE="$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"

        umu-run "$BNET_EXE"
      '';
    };
  in {
    packages = {
      ${system} = {
        inherit battlenet;
        default = self.packages.${system}.battlenet;
      };
    };
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = [battlenet];
        };
      };
    };
  };
}
