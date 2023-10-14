{

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.systems.url = "github:msfjarvis/flake-systems";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";

  inputs.flake-compat.url = "github:nix-community/flake-compat";
  inputs.flake-compat.flake = false;

  inputs.go2nix.url = "github:nix-community/gomod2nix/master";
  inputs.go2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.go2nix.inputs.flake-utils.follows = "flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    go2nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [go2nix.overlays.default];
      };
    in {
      packages.default = pkgs.buildGoApplication {
        pname = "gphotos-cdp";
        version = "1.0.0";
        pwd = ./.;
        src = ./.;
        modules = ./gomod2nix.toml;
      };
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          git
          gomod2nix
          (mkGoEnv {pwd = ./.;})
        ];
      };
    });
}
