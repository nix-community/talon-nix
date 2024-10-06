{
  stdenvNoCC,
  lib,
  fetchurl,
  pname,
  version,
  meta,
  hash ? "",
  undmg
}:
stdenvNoCC.mkDerivation {
  inherit pname version;
  src = fetchurl {
    url = "https://talonvoice.com/dl/latest/talon-mac.dmg";
    name = "Talon-${version}.dmg";
    inherit hash;
  };

  sourceRoot = ".";
  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications/Talon.app"
    cp -R *.app "$out/Applications"
    runHook postInstall
  '';

  meta = meta // {
    platforms = with lib.platforms; darwin;
  };
}