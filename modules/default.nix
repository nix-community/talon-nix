{ config, lib, pkgs, ... }:

let
  cfg = config.programs.talon;

in
{
  options.programs.talon = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc ''
        Installs talon and configures udev rules for hardware
        used by talon.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ (import ../overlay.nix) ];
    services.udev.packages = [ pkgs.talon ];
    environment.systemPackages = [ pkgs.talon ];
  };
}
