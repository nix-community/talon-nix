{ stdenv
, lib
, callPackage
}:
let
  pname = "talon";
  version = "0.40.0";
  meta = with lib; {
    homepage = "https://talonvoice.com/";
    description = "Voice control application";
    license = licenses.unfree;
    maintainers = [ ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
  linux = callPackage ./talon/linux.nix {
    inherit pname version meta;
  };
  darwin = callPackage ./talon/darwin.nix {
    inherit pname version meta;
    hash = "sha256-QC+LSsFy2XNg47YMN1PmUr2sxAj5K3lUf5bDThrLZ70=";
  };
in if stdenv.hostPlatform.isDarwin
then darwin
else linux

