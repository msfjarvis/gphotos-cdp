{
  inputs = {
    nixpkgs = {url = "github:NixOS/nixpkgs/nixpkgs-unstable";};
    flake-utils = {url = "github:numtide/flake-utils";};
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    go2nix = {
      url = "github:nix-community/gomod2nix/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
  };

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
