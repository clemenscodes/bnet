{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    umu = {
      url = "git+https://github.com/Open-Wine-Components/umu-launcher/?dir=packaging\/nix&submodules=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    umu = inputs.umu.packages.${pkgs.system}.umu.override {version = "${inputs.umu.shortRev}";};
  in {
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.curl
            pkgs.samba
            (pkgs.wineWowPackages.waylandFull.override {
              wineRelease = "staging";
              mingwSupport = true;
            })
            pkgs.winetricks
            umu
          ];
        };
      };
    };
  };
}
