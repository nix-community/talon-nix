final: prev: {
  talon-unwrapped =
    if prev ? talon-unwrapped then prev.talon-unwrapped else prev.callPackage ./talon-unwrapped.nix { };
  talon = prev.callPackage ./talon.nix { pkgs = final; };
}
