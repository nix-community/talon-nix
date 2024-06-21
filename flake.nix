{
  description = "Automatically managed Nix packages for Talon Voice";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nix-github-actions.url = "github:nix-community/nix-github-actions";
  inputs.nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";

  outputs =
    {
      self,
      nixpkgs,
      nix-github-actions,
    }:
    let
      system = "x86_64-linux";
      overlays = import ./overlay.nix;
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlays ];
      };
    in
    {
      overlays.default = overlays;
      nixosModules.talon = import ./nixos;

      githubActions = nix-github-actions.lib.mkGithubMatrix { inherit (self) checks; };

      checks.${system} = {
        talon = self.packages.${system}.default;
      };

      packages.${system} = {
        default = self.packages.${system}.talon;
        talon = pkgs.talon;
        talon-unwrapped = pkgs.talon-unwrapped;
      };
      devShells.${system}.default = import ./shell.nix { inherit pkgs; };
    };
}
