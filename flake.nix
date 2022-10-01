{
  description = "Automatically managed Nix packages for Talon Voice";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils }:
    {
      overlays.default = import ./overlay.nix;
      nixosModules.talon = import ./nixos;
    } //
    (utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          packages.default = pkgs.callPackage ./talon.nix { };
          devShells.default = import ./shell.nix { inherit pkgs; };
        })
    );
}
