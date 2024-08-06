{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  inputs.systems.url = "github:msfjarvis/flake-systems";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.devshell.inputs.nixpkgs.follows = "nixpkgs";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";

  inputs.flake-compat.url = "github:nix-community/flake-compat";
  inputs.flake-compat.flake = false;

  inputs.gomod2nix.url = "github:nix-community/gomod2nix/master";
  inputs.gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.gomod2nix.inputs.flake-utils.follows = "flake-utils";

  outputs = {
    self,
    nixpkgs,
    devshell,
    flake-utils,
    gomod2nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [devshell.overlays.default gomod2nix.overlays.default];
      };
    in {
      packages.default = pkgs.buildGoApplication {
        pname = "gphotos-cdp";
        version = "1.0.0";
        pwd = ./.;
        src = ./.;
        modules = ./gomod2nix.toml;
        meta = {mainProgram = "gphotos-cdp";};
      };
      devShells.default = pkgs.devshell.mkShell {
        bash = {interactive = "";};

        env = [
          {
            name = "DEVSHELL_NO_MOTD";
            value = 1;
          }
        ];

        packages = with pkgs; [
          git
          go
          gomod2nix.packages.${system}.default
          go-outline
          gopls
          gotools
          (mkGoEnv {pwd = ./.;})
        ];
      };
    })
    // {
      overlays.default = final: _: {
        gphotos-cdp = self.packages.${final.system}.default;
      };
    };
}
