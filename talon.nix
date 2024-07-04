{
  buildFHSEnv,
  lib,
  pkgs,
}:
let
  meta = {
    homepage = "https://talonvoice.com/";
    description = "Voice coding application. FHS wrapped.";
    license = lib.licenses.unfree;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
in
buildFHSEnv {
  name = "talon";

  profile = ''
    unset QT_AUTO_SCREEN_SCALE_FACTOR QT_SCALE_FACTOR
    export LC_NUMERIC=C
    export QT_PLUGIN_PATH="/lib/plugins"

    export LD_LIBRARY_PATH=${
      lib.concatStringsSep ":" [
        "/opt/talon/resources/python/lib/python3.11/site-packages/numpy.libs"
        "/opt/talon/resources/python/lib"
      ]
    }
  '';

  extraInstallCommands = ''
    ln -s ${pkgs.talon-unwrapped}/share $out/share
    ln -s ${pkgs.talon-unwrapped}/etc $out/etc
  '';

  runScript = "${pkgs.talon-unwrapped}/bin/talon";

  targetPkgs =
    pkgs: with pkgs; [
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
      talon-unwrapped
    ];

  inherit meta;
}
