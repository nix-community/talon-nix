{
  description = "Automatically managed Nix packages for Talon Voice";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  # Switched to the numtide nixpkgs-unfree path to ensure that consumers aren't getting extra instances of nixpkgs if possible
  inputs.nixpkgs-unfree.url = "github:numtide/nixpkgs-unfree?ref=nixos-unstable";
  inputs.nixpkgs-unfree.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nix-github-actions.url = "github:nix-community/nix-github-actions";
  inputs.nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, nix-github-actions, nixpkgs-unfree }:
    let
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      # Use to avoid accidentally introducing multiple nixpkgs: 
      # https://discourse.nixos.org/t/using-nixpkgs-legacypackages-system-vs-import/17462/8
      forAllSystemsPkgs = usePkgs:
        lib.genAttrs systems (system: usePkgs nixpkgs-unfree.legacyPackages.${system});
      forAllSystems = useSystem:
        lib.genAttrs systems (system: useSystem system);
    in
    {
      overlays.default = import ./overlay.nix;
      nixosModules.talon = import ./modules;
      darwinModules.talon = import ./modules;
      checks = forAllSystems (system: { talon = self.packages.${system}.default; });
      packages = forAllSystemsPkgs (pkgs: { default = pkgs.callPackage ./talon.nix { }; });
      devShells = forAllSystemsPkgs (pkgs: { default = import ./shell.nix { inherit pkgs; }; });
      githubActions = nix-github-actions.lib.mkGithubMatrix { inherit (self) checks; };
    };
}
