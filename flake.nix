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
    {
      overlays.default = final: prev: {
        comity = final.callPackage ./comity.nix { };
      };
      # shell = ./shell.nix;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            bats-require.overlays.default
            self.overlays.default
          ];
        };
      in
        {
          packages = {
            inherit (pkgs) comity;
            default = pkgs.comity;
          };
          checks = pkgs.callPackages ./test.nix {
            inherit (pkgs) comity;
          };
          devShells = {
            default = pkgs.mkShell {
              # arcane because we want to hand the user an empty shell
              # but we do want to go ahead and source the script.
              shellHook = ''
                exec env -i PATH=$PATH HOME=$(mktemp -d) PROMPT_COMMAND="source '${pkgs.comity}/bin/comity.bash'; unset PROMPT_COMMAND" ${pkgs.bashInteractive}/bin/bash --norc  --noprofile -i
              '';
            };
          };
        }
    );
}
