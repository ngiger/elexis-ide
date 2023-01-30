#! /usr/bin/env nix-shell
# call it: nix-shell ./start_h2.sh
# mit GDK_BACKEND=wayland läuft copy/paste zu kate nicht
# install package at-spi2-core to avoid error
# AT-SPI: Error retrieving accessibility bus address: org.freedesktop.DBus.Error.ServiceUnknown: The name org.a11y.Bus was not provided by any .service files
{
  stdenv,
  writeShellApplication,
  pkgs,
  lib,
  system,
  callPackage,
}: 
  let mvn = pkgs.maven.override { jdk = pkgs.jdk17; };
  neededPkgs = with pkgs; [
      zlib
      dbus
      atk # libatk-1.0.so
      cairo # needed to run Elexis h2
      at-spi2-core
      git
      glib
      glib-networking
      gnulib
      gsettings-desktop-schemas
      gtk3
      nss_latest
      nspr
      libdrm
      xorg.libXdamage
      mesa
      alsa-lib
      swt
      gvfs
      jdk17
      librsvg
      libsecret
      libzip
      openssl
      stdenv
      stdenv.cc.cc
      unzip
      webkitgtk
      xorg.libXtst
      xorg.libXtst
      xorg.libX11
      xorg.xauth      
      xfce.xfce4-session
    ];
    NIX_LD_LIBRARY_PATH = lib.makeLibraryPath neededPkgs;
    NIX_LD = builtins.readFile "${stdenv.cc}/nix-support/dynamic-linker";
in pkgs.writeShellApplication {
  runtimeInputs = neededPkgs;
    name = "elexis-IDE";
    text = with pkgs; ''
      version=$(echo ${gtk3}  | cut -d '-' -f 3)
      export NIX_LD_LIBRARY_PATH="${NIX_LD_LIBRARY_PATH}"
      GIO_MODULE_DIR=${glib-networking}/lib/gio/modules/
      echo GIO_MODULE_DIR are $GIO_MODULE_DIR
      XDG_DATA_DIRS="$XDG_DATA_DIRS:${gtk3}/share/gsettings-schemas/gtk+3-$version:${at-spi2-core}/share/dbus-1/services" # this worked! Tested using File..Open
      GDK_BACKEND=x11
      GSETTINGS_SCHEMA_DIR=${at-spi2-core}/share/dbus-1/services
      echo GSETTINGS_SCHEMA_DIR are "$GSETTINGS_SCHEMA_DIR"
      echo "done shellHook version is" "$version" with GDK_BACKEND "$GDK_BACKEND"
      echo "${xorg.xhost}/bin/"
      echo NIX_LD_LIBRARY_PATH is "$NIX_LD_LIBRARY_PATH"
      env > ./tmp.tmp
      echo before XDG_
      echo ""
      env | grep XDG_
      echo nach XDG_
      env | grep NIX_LD_
      # "${xorg.xhost}"/bin/xhost +si:localuser:root
      echo "RPCTT is ${pkgs.rcptt}/bin"
      bash -i
    '';
  }
