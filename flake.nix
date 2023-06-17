{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.pnpm2nix = {
    url = "github:Ninlives/pnpm2nix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs, pnpm2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system}.appendOverlays
          [ pnpm2nix.overlays.default ];
      in {
        packages = rec {
          misskey = pkgs.callPackage ./package.nix { };
          default = misskey;
        };
      }) // {
        overlays.default = final: prev: {
          misskey =
            (final.extend pnpm2nix.overlays.default).callPackage ./package.nix
            { };
        };
        nixosModules = rec {
          misskey = { ... }: {
            nixpkgs.overlays = [ self.overlays.default ];
            imports = [ ./module.nix ];
          };
          default = misskey;
        };
      };
}
