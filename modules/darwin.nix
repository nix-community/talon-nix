{ config, lib, pkgs, ... }:

let
  cfg = config.programs.talon;

in
{
  imports = [ ./system.nix ];

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ (import ../overlay.nix) ];
    environment.systemPackages = [ pkgs.talon ];
  };
}