{ stdenv
, lib
, callPackage
}:
let
  inherit (lib.importJson ./talon/info.json) version linux darwin;
  pname = "talon";
  meta = with lib; {
    homepage = "https://talonvoice.com/";
    description = "Voice control application";
    license = licenses.unfree;
    maintainers = [ ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
  linuxPkg = callPackage ./talon/linux.nix {
    inherit pname version meta;
    inherit (linux) sha256;
  };
  darwinPkg = callPackage ./talon/darwin.nix {
    inherit pname version meta;
    inherit (darwin) sha256;
  };
in if stdenv.hostPlatform.isDarwin
then darwinPkg
else linuxPkg

