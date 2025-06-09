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
  gtk4,
  jdk11,
  jdk21,
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
  webkitgtk_4_0,
  xorg,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "rcptt";
  version = "2.5.5";
  src = fetchzip {
    url = "https://download.eclipse.org/rcptt/release/${version}/ide/rcptt.ide-${version}-linux.gtk.x86_64.zip";
    sha256 = "sha256-SttZKFg8XQqr+7nZo0tPx6VoRASg5GWyZeO07EsgrlI=";
  };

  buildInputs = with xorg; [
    gsettings-desktop-schemas
    makeWrapper
  ];

  desktopItem = makeDesktopItem {
    name = "RCPTT";
    exec = "rcptt";
    icon = "rcptt";
    comment = "RCP Testing Tool is a project for GUI testing automation of Eclipse-based applications.";
    desktopName = "RCPTT";
    genericName = "RCP Testing Tool";
    categories = ["Development" "IDE" "Java"];
  };

  unpackPhase = ''
    cp -rp $src/ $out/
  '';

  installPhase = with xorg; ''
    chmod +w $out
    interpreter=$(echo ${pkgs.glibc.out}/lib/ld-linux*.so.2)
    libCairo=$out/eclipse/libcairo-swt.so
    chmod +w $out/rcptt
    patchelf --set-interpreter $interpreter $out/rcptt
    patchelf --set-rpath ${lib.makeLibraryPath [
      freetype
      fontconfig
      nss
      at-spi2-core
      gsettings-desktop-schemas
      libX11
      libXrender
      zlib
      jdk21
      gtk4
      glib-networking
      webkitgtk_4_0
      nss
      nspr
      libdrm
      xorg.libXdamage
      mesa
      alsa-lib
    ]} $out/rcptt
    productId=${pname}
    productVersion=${version}
    export gtk4_version=`echo ${gtk4}  | cut -d '-' -f 3`
    makeWrapper $out/rcptt $out/bin/rcptt \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [glib gtk4 libX11 libXext libXi libXrender libXtst libsecret webkitgtk_4_0 zlib jdk11 jdk21]} \
      --prefix XDG_DATA_DIRS : "$XDG_DATA_DIRS:${gtk4}/share/gsettings-schemas/gtk+4-$gtk4_version" \
      --prefix NO_AT_BRIDGE : 1 \
      --prefix GDK_BACKEND : x11 \
      --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
      --add-flags "-configuration \$HOME/.eclipse/''${productId}_$productVersion/configuration"
    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications
    mkdir -p $out/share/pixmaps
    mv $out/icon.xpm $out/share/pixmaps/rcptt.xpm
    sed -i 's/-Xmx768m/-Xmx1536m/' $out/rcptt.ini
  '';

  meta = with lib; {
    homepage = "https://www.eclipse.org/rcptt";
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
