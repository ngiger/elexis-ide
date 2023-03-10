#! /usr/bin/env nix-shell
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/nixos-22.11.tar.gz

# '/opt/ide/2022.03/;' has 7.2 GB, git subdir has 6.9GB of it
# see https://bugs.eclipse.org/bugs/show_bug.cgi?id=487626
# https://github.com/a-langer/eclipse-oomph-console
# > mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:unpack -Dartifact=com.github.a-langer:org.eclipse.oomph.console.product:LATEST:tar.gz:linux.gtk.x86_64 -DoutputDirectory=./ -Dproject.basedir=./ # 80 M
# ./eclipse-installer/eclipse-inst # needs NIX_LD
# custom setup 
# https://github.com/a-langer/eclipse-oomph-console/tree/main/org.eclipse.oomph.console.product/setups


with import <nixpkgs> {};
pkgs.mkShell {
  NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
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
      nss_latest nspr libdrm xorg.libXdamage mesa alsa-lib
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
    ];
  NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
  buildInputs = [ pkgs.maven ];
}
