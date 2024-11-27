{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
  };
  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    devShells = {
      ${system} = {
        default = pkgs.mkShell {
          buildInputs = [
            pkgs.curl
            pkgs.samba
            (pkgs.wineWowPackages.full.override {
              wineRelease = "staging";
              mingwSupport = true;
            })
            pkgs.winetricks
          ];
        };
      };
    };
  };
}
