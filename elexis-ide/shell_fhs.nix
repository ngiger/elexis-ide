{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSUserEnv {
  name = "simple-x11-env";
  targetPkgs = pkgs: (with pkgs;
    [ udev
      alsa-lib
      fish
      unzip
      which
      strace
       adoptopenjdk-hotspot-bin-11
       ruby 
       rubyPackages.rugged
      maven
      vim
      # Following lines needed to start Elexis3
      glibc
      zlib
      freetype
      fontconfig
      glib
      gtk3
      gtk3-x11
      libsecret
      swt
      librsvg
      # see also https://nixos.org/manual/nixpkgs/unstable/#ssec-gnome-packaging
      # circumvent error (SWT:1205135): GLib-GIO-ERROR **: 11:13:19.855: No GSettings schemas are installed on the system
      # to be able to open a file e.g. for artikelstamm import
      gsettings-desktop-schemas
      wrapGAppsHook
      gdk-pixbuf
      dconf
      glib-networking
      gvfs
      # programs called from Elexis e.g. text application
#      libreoffice-qt
      acl
    ]) ++ (with pkgs.xorg;
    [ 
      libXcursor
      libXrandr
      # needed for Elexis3
      libXrender
      libX11
      libXtst
      xhost
    ]);
  runScript = "bash";
    profile = ''
    export XAUTHORITY=$XDG_RUNTIME_DIR/xauth_GKFuxE
  '';
}).env
