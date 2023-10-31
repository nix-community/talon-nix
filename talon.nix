{ stdenv
, buildFHSEnv
, lib
, fetchurl
}:

let
  inherit (lib.importJSON ./src.json) version sha256;

  meta = {
    homepage = "https://talonvoice.com/";
    description = "Voice coding application";
    license = lib.licenses.unfree;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };

  talon = stdenv.mkDerivation {
    pname = "talon";
    inherit version;

    src = fetchurl {
      url = "https://talonvoice.com/dl/latest/talon-linux.tar.xz";
      inherit sha256;
    };

    preferLocalBuild = true;
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/talon
      cp -a * $out/opt/talon/

      mkdir -p "$out/etc/udev/rules.d"
      cp 10-talon.rules $out/etc/udev/rules.d
      # Remove udev compatibility hack using plugdev for older debian/ubuntu
      # This breaks NixOS usage of these rules (see https://github.com/NixOS/nixpkgs/issues/76482)
      substituteInPlace $out/etc/udev/rules.d/10-talon.rules --replace 'GROUP="plugdev",' ""

      mkdir -p $out/share/applications
      cat << EOF > $out/share/applications/talon.desktop
        [Desktop Entry]
        Categories=Utility;
        Exec=talon
        Name=Talon
        Terminal=false
        Type=Application
      EOF

      mkdir -p $out/bin
      ln -s $out/opt/talon $out/bin/talon

      runHook postInstall
    '';

    inherit meta;
  };

in
buildFHSEnv {
  name = "talon";

  profile = ''
    unset QT_AUTO_SCREEN_SCALE_FACTOR QT_SCALE_FACTOR
    export LC_NUMERIC=C
    export QT_PLUGIN_PATH="/lib/plugins"

    export LD_LIBRARY_PATH=${lib.concatStringsSep ":" [
      "/opt/talon/resources/python/lib/python3.11/site-packages/numpy.libs"
      "/opt/talon/resources/python/lib"
    ]}
  '';

  extraInstallCommands = ''
    ln -s ${talon}/share $out/share
    ln -s ${talon}/etc $out/etc
  '';

  runScript = "talon";

  targetPkgs = pkgs: with pkgs; [
    stdenv.cc.cc
    stdenv.cc.libc
    dbus
    fontconfig
    freetype
    glib
    libGL
    libxkbcommon
    sqlite
    zlib
    libpulseaudio
    udev
    xorg.libX11
    xorg.libSM
    xorg.libXcursor
    xorg.libICE
    xorg.libXrender
    xorg.libxcb
    xorg.libXext
    xorg.libXcomposite
    xorg.libXrandr
    xorg.libXi
    bzip2
    ncurses5
    libuuid
    gtk3-x11
    gdk-pixbuf
    cairo
    libdrm
    gnome2.pango
    gdbm
    atk
    wayland
    wayland-protocols
    wlroots
    xwayland
    libinput
    libxml2
    speechd
    gfortran
    # gfortran.cc default output contains static libraries compiled without -fPIC
    # we want libgfortran.so instead (see: https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/science/math/giac/default.nix)
    (lib.getLib gfortran.cc)
    talon
  ];

  inherit meta;
}
