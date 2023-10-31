{
  description = "Automatically managed Nix packages for Talon Voice";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nix-github-actions.url = "github:nix-community/nix-github-actions";
  inputs.nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nix-github-actions }:
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  in
  {
    overlays.default = import ./overlay.nix;
    nixosModules.talon = import ./nixos;

    githubActions = nix-github-actions.lib.mkGithubMatrix { inherit (self) checks; };

    checks.x86_64-linux = {
      talon = self.packages.x86_64-linux.default;
    };

    packages.x86_64-linux.default = pkgs.callPackage ./talon.nix { };
    devShells.x86_64-linux.default = import ./shell.nix { inherit pkgs; };
  };
}
