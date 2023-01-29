{ pkgs, inputs, ... }:
# https://www.azul.com/products/azul-support-roadmap/
# elexis-master needs openjdk17
# I found no elegant solution to put the long list of packages into a variable.
{
  languages.java.enable = true;
  packages = [
    pkgs.openjdk
    pkgs.wrapGAppsHook
    pkgs.dbus
    pkgs.atk # libatk-1.0.so
    pkgs.cairo # needed to run Elexis h2
    pkgs.at-spi2-core
    pkgs.git
    pkgs.glib
    pkgs.glib-networking
    pkgs.gnulib
    pkgs.gsettings-desktop-schemas
    pkgs.gtk3
    pkgs.nss_latest
    pkgs.nspr
    pkgs.libdrm
    pkgs.xorg.libXdamage
    pkgs.mesa
    pkgs.alsa-lib
    pkgs.swt
    pkgs.gvfs
    pkgs.jdk17
    pkgs.librsvg
    pkgs.libsecret
    pkgs.libzip
    pkgs.openssl
    pkgs.stdenv
    pkgs.stdenv.cc.cc
    pkgs.unzip
    pkgs.webkitgtk
    pkgs.xorg.libXtst
  ];
  pre-commit.hooks.shellcheck.enable = true;

#  environment.NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";

  enterShell = ''
    echo 'Making sure the basics for native compilation are available:'
    mvn --version
    export NIX_LD="${pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"}";
    export NIX_LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.zlib
      pkgs.dbus
      pkgs.atk # libatk-1.0.so
      pkgs.cairo # needed to run Elexis h2
      pkgs.at-spi2-core
      pkgs.git
      pkgs.glib
      pkgs.glib-networking
      pkgs.gnulib
      pkgs.gsettings-desktop-schemas
      pkgs.gtk3
      pkgs.nss_latest
      pkgs.nspr
      pkgs.libdrm
      pkgs.xorg.libXdamage
      pkgs.mesa
      pkgs.alsa-lib
      pkgs.swt
      pkgs.gvfs
      pkgs.jdk17
      pkgs.librsvg
      pkgs.libsecret
      pkgs.libzip
      pkgs.openssl
      pkgs.stdenv
      pkgs.stdenv.cc.cc
      pkgs.unzip
      pkgs.webkitgtk
      pkgs.xorg.libXtst
    ]}"
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/gtk+3-$version:${pkgs.at-spi2-core}/share/dbus-1/services"
    export GSETTINGS_SCHEMA_DIR="${pkgs.glib.getSchemaPath pkgs.gtk3}:${pkgs.at-spi2-core}/share/dbus-1/services"
    ls -l "${pkgs.bash}/bin/bash"
    export GIO_MODULE_DIR=${pkgs.glib-networking}/lib/gio/modules/
    echo GSETTINGS_SCHEMA_DIR sind $GSETTINGS_SCHEMA_DIR
  '';
}
