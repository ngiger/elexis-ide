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
}: let   neededPackages = [
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
  eclipseSetup = builtins.toFile "org.eclipse.setup" (builtins.readFile ./org.eclipse.setup);
  productsSetup = builtins.toFile "products.setup" (builtins.readFile ./products.setup);
  projectsSetup = builtins.toFile "projects.setup" (builtins.readFile ./projects.setup);
in stdenv.mkDerivation rec {
  pname = "Elexis-IDE";
  version = "2022-12";
  src = fetchzip {
    url = "https://repo1.maven.org/maven2/com/github/a-langer/org.eclipse.oomph.console.product/1.0.2/org.eclipse.oomph.console.product-1.0.2-linux.gtk.x86_64.tar.gz";
    sha256 = "sha256-gfaNFJS0oX3inJqMmFZFiakyiY7QqupKKmBR0/5vXmU="; # found using pkgs.lib.fakeSha256;
  };

  buildInputs = with xorg; [
    gsettings-desktop-schemas
    makeWrapper
    pkgs.maven
    pkgs.rsync
    pkgs.openjdk
  ];

  desktopItem = makeDesktopItem {
    name = "Elexis-IDE";
    exec = "rcptt";
    icon = "rcptt";
    comment = "RCP Testing Tool is a project for GUI testing automation of Eclipse-based applications.";
    desktopName = "Elexis-IDE";
    genericName = "RCP Testing Tool";
    categories = ["Development" "IDE" "Java"];
  };
/*
    export NIX_LD="${pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker"}";
    export NIX_LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath neededPackages}"
*/
  buildPhase = ''
    set -o verbose
    echo installPhase src is $src with NIX_LD out is $out
    rsync -a $src/ $out/
    du -shx $src/ $out/
    find $src -name eclipse-inst
    export INST_ROOT="$out"
    export WORKSPACE="$out/workspace"
    export WORKSPACE="$out/p2_pool"
    export SETUPS="$out/setups"
    export NIX_LD=
    export NIX_LDFLAGS=
    export USER_HOME="$out/home"
    env | grep NIX_LD
    ls -l $src/eclipse-inst
    chmod -R +w $out
    mkdir -p $out/myconfig
    chmod -R +w $out/myconfig
    interpreter=$(echo ${pkgs.glibc.out}/lib/ld-linux*.so.2)
    libCairo=$out/eclipse/libcairo-swt.so
    cp -v $src/eclipse-inst $out/eclipse-inst 
    chmod +w $out/eclipse-inst
    patchelf --set-interpreter $interpreter $out/eclipse-inst
    cp "${eclipseSetup}"  $SETUPS/org.eclipse.setup
    cp "${productsSetup}" $SETUPS/products.setup
    cp "${projectsSetup}" $SETUPS/projects.setup
    patchelf --set-rpath ${lib.makeLibraryPath neededPackages} $out/eclipse-inst
    file $out/eclipse-inst
    cd $out
    makeWrapper $out/eclipse-inst $out/wrappedInstaller \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath neededPackages} \
      --prefix XDG_DATA_DIRS : "$XDG_DATA_DIRS:${gtk3}/share/gsettings-schemas/gtk+3-$gtk3_version" \
      --prefix NO_AT_BRIDGE : 1 \
      --prefix GDK_BACKEND : x11 \
      --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
      --add-flags "-configuration \$out/.eclipse/''${productId}_$productVersion/configuration"
    ls -lrta $out/wrappedInstaller $out/myconfig $out/eclipse-inst $SETUPS
    file $out/wrappedInstaller
    $out/wrappedInstaller -nosplash --headless -shared="$INST_ROOT/p2_shared"  -application org.eclipse.oomph.console.application -vmargs \
      -Doomph.redirection.setups="index:/->$SETUPS/" \
      -Doomph.installation.location="$INST_ROOT" \
      -Doomph.product.id="eclipse.ide4elexis" \
      -Doomph.project.id="elexis.ide" \
      -Doomph.workspace.location="$WORKSPACE" \
      -Dworkspace.location="$WORKSPACE" \
      -Dsetup.p2.agent="$P2_POOL" \
      -Duser.home="$USER_HOME" \
      -Doomph.setup.offline=false \
      -Dgit.container.root="$GIT_ROOT" \
      -Doomph.installer.verbose=true 2>&1 | tee $0.log
  '';

  installPhase2 = with xorg; ''
    set -o verbose
    echo dummy installPhase
    exit 
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
      openjdk11
      openjdk17
      gtk3
      glib-networking
      webkitgtk
      nss
      nspr
      libdrm
      xorg.libXdamage
      mesa
      alsa-lib
    ]} $out/rcptt
    productId=${pname}
    productVersion=${version}
    export gtk3_version=`echo ${gtk3}  | cut -d '-' -f 3`
    makeWrapper $out/rcptt $out/bin/rcptt \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [glib gtk3 libX11 libXext libXi libXrender libXtst libsecret webkitgtk zlib openjdk11 openjdk17]} \
      --prefix XDG_DATA_DIRS : "$XDG_DATA_DIRS:${gtk3}/share/gsettings-schemas/gtk+3-$gtk3_version" \
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
      Elexis-IDE is fully aware about Eclipse Platform's internals, hiding this complexity from end users
      and allowing QA engineers to create highly reliable UI tests at great pace.
    '';
    maintainers = with maintainers; [ngiger];
    license = licenses.epl20;
    sourceProvenance = with sourceTypes; [binaryNativeCode];
    platforms = ["x86_64-linux"];
  };
}
