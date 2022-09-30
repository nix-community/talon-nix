let
  pkgs = import <nixpkgs> { };

  pythonEnv = pkgs.python3.withPackages (ps: [
    ps.requests
    ps.beautifulsoup4

  ]);
in
pkgs.mkShell {
  packages = [ pythonEnv ];
}
