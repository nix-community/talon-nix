{ pkgs ? import <nixpkgs> {
    overlays = [
      (import ./overlay.nix)
    ];
  }
}: pkgs.talon
