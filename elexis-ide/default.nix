{ pkgs, lib, stdenv, makeDesktopItem, makeWrapper, ... }:

let 
  neededPackages = [
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
  rcp_icon =  builtins.path {
    path = ./icon.xpm;
    name = "rcp_icon.xpom";
  };
  header =''
      export NIX_LD="${pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"}";
      export NIX_LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath neededPackages}"
  '';
  mainContent = (builtins.readFile ../setup_elexis.sh);
  shellScript = pkgs.writeShellApplication {
    name = "startElexisIde";
    runtimeInputs = neededPackages;
    text = ''
    ${header}
    ${mainContent}
    ''; # this works, too! 
  };
  desktopItem = makeDesktopItem {
    name = "Elexis-IDE";
    exec = "${shellScript}/bin/startElexisIde";
    icon = rcp_icon;
    comment = "Integrated Development Environment";
    desktopName = "Eclipse IDE for Elexis";
    genericName = "Integrated Development Environment";
    categories = [ "Development" ];
  };
  
in stdenv.mkDerivation {
  src = ./. ;
  name = "niklaus";
#  __impure = true; # marks this derivation as impure
  buildPhase = ''
  set -o verbose
   mkdir -p  $out/bin
   cp -v ${shellScript}/bin/* $out/bin/
  mkdir -p $out/share/applications
  cp ${desktopItem}/share/applications/* $out/share/applications
   ls -lR $out
  '';
  installPhase = ''
    echo Dummy installPhase
  '';
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = neededPackages;
  desktopItem = desktopItem;
  meta = {
    homepage = "https://www.eclipse.org/";
    description = "Elexis-IDE";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };

}
