{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    bats-require = {
      url = "github:abathur/bats-require";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  # description = "Bash library for neighborly signal sharing";

  outputs = { self, nixpkgs, flake-utils, flake-compat, bats-require }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              bats-require = bats-require.packages."${system}".default;
            })
          ];
        };
      in
        rec {
          packages.comity = pkgs.callPackage ./comity.nix { };
          packages.default = self.packages.${system}.comity;
          checks = pkgs.callPackages ./test.nix {
            inherit (packages) comity;
          };
        }
    );
}
