{
  lib,
  pkgs,
  stdenv,
  at-spi2-core,
  fetchzip,
  fontconfig,
  freetype,
  glib,
  glib-networking,
  gsettings-desktop-schemas,
  gtk3,
  openjdk11,
  openjdk17,
  libsecret,
  makeDesktopItem,
  makeWrapper,
  nss,
  nspr,
  libdrm,
  mesa,
  alsa-lib, # for chromium
  # Caused by: org.eclipse.swt.SWTException: To run Chromium on Wayland, set env var GDK_BACKEND=x11 or call ChromiumBrowser.earlyInit() before creating Display
  unzip,
  webkitgtk,
  xorg,
  zlib,
  perl,
}:
let elexisZip = pkgs.fetchurl {
    url = "https://download.elexis.info/elexis/3.9/products/Elexis3-linux.gtk.x86_64.zip";
    sha256 = "sha256-j3JEZ2m9zG5kE58LFLk42qDkq5D6yVdmnimfH7062AY="; # or lib.fakeSha256;
  };
  neededLibraries =  [
      freetype
      fontconfig
      nss
      at-spi2-core
      gsettings-desktop-schemas
      xorg.libX11
      xorg.libXrender
      zlib
      gtk3
      glib-networking
      webkitgtk
      nss
      nspr
      libdrm
      xorg.libXdamage
      mesa
      pkgs.libcap
      xorg.libxcb
      alsa-lib
    ];
in stdenv.mkDerivation rec {
  pname = "elexis";
  version = "3.9";
  # nix-prefetch-url https://download.elexis.info/elexis/3.9/products/Elexis3-linux.gtk.x86_64.zip
# evtl --unpack --name Elexis-3.9-linux-x86_64.zip
# path is '/nix/store/h8gi9prs6bwgrac61fnvfd0ng004cf4g-Elexis3-linux.gtk.x86_64.zip'
# 1r1pa5wz3p76s72kgbx0nm77f8fd834snc7gl1gww0dnzpyx0wqj

  buildInputs = with xorg; [
    gsettings-desktop-schemas
    makeWrapper
    unzip
    perl
  ];

  desktopItem = makeDesktopItem {
    name = "elexis";
    exec = "Elexis3";
    icon = "elexis";
    comment = "Elexis3 an all-encompassing tool for a medical practices";
    desktopName = "Elexis";
    genericName = "Elexis3";
    categories = ["Office"];
  };

  unpackPhase = ''
    echo "${elexisZip}"
    unzip -d $out/ ""${elexisZip}""
  '';

  installPhase = with xorg; ''
    echo $out
    ls -lrta $out
    chmod +w $out
    interpreter=$(echo ${pkgs.glibc.out}/lib/ld-linux*.so.2)
    libCairo=$out/eclipse/libcairo-swt.so
    chmod +w $out/Elexis3
    patchelf --set-interpreter $interpreter $out/Elexis3
    patchelf --set-rpath ${lib.makeLibraryPath neededLibraries} $out/Elexis3
    productId=${pname}
    productVersion=${version}
    export gtk3_version=`echo ${gtk3}  | cut -d '-' -f 3`
    makeWrapper $out/Elexis3 $out/bin/Elexis3 \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath neededLibraries} \
      --prefix XDG_DATA_DIRS : "$XDG_DATA_DIRS:${gtk3}/share/gsettings-schemas/gtk+3-$gtk3_version" \
      --prefix NO_AT_BRIDGE : 1 \
      --prefix GDK_BACKEND : x11 \
      --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \

    #  --add-flags "-consoleLog -configuration \$HOME/.eclipse/''${productId}_$productVersion/configuration"
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
    mkdir -p $out/share/pixmaps
    cp $out/icon.xpm $out/share/pixmaps/elexis.xpm
    # sed -i 's/-Xmx768m/-Xmx1536m/' $out/Elexis3.ini
    # ensure Elexis3.ini does not try to use a justj jvm, as those aren't compatible with nix
    ${perl}/bin/perl -i -p0e 's|-vm\nplugins/org.eclipse.justj.*/jre/bin\n||' $out/Elexis3.ini
  '';

  meta = with lib; {
    homepage = "https://www.eclipse.org/elexis";
    description = "RCP Testing Tool for Eclipse RCP applications";
    longDescription = ''
      RCP Testing Tool is a project for GUI testing automation of Eclipse-based applications.
      RCPTT is fully aware about Eclipse Platform's internals, hiding this complexity from end users
      and allowing QA engineers to create highly reliable UI tests at great pace.
    '';
    maintainers = with maintainers; [ngiger];
    license = licenses.epl20;
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    platforms = ["x86_64-linux"];
  };
}
