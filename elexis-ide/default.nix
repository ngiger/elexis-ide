{
  stdenv,
  writeShellApplication,
  pkgs,
  fetchFromGitHub,
  bundler,
  bundlerApp,
  bundlerEnv,
  bundlerUpdateScript,
  system,
  callPackage,
}: let
  neededPackages = [
    pkgs.busybox # to call readlink in bash shell
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
in  
  pkgs.makeDesktopItem {
    name = "Elexis-IDE";
    exec = "${shellScript}/bin/startElexisIde";
    icon = rcp_icon;
    comment = "Start (or download) Elexis-IDE 2022-12";
    desktopName = "Elexis-IDE";
    genericName = "Elexis-IDE 2022";
    categories = ["Development" "IDE" "Java"];
  }
