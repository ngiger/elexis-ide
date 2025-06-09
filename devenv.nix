{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.LANG= "de_CH.UTF-8";
  env.LC_MESSAGES= "de_CH.UTF-8";
  env.LC_ALL= "de_CH.UTF-8";
  env.GTK_IM_MODULE = "ibus";
  env.NO_AT_BRIDGE = "1";
# pkgs.gtk3 pkgs.gtk+3 pkgs.gtk pkgs.steam-run
  packages = [ pkgs.git pkgs.gtk3 pkgs.steam-run pkgs.webkitgtk_4_1 pkgs.libsecret pkgs.glib-networking ];
  env.LD_LIBRARY_PATH = "${pkgs.gtk3}/lib;${pkgs.webkitgtk_4_0}/lib;${pkgs.libsecret}/lib;";
  env.GIO_MODULE_DIR="${pkgs.glib-networking}/lib/gio/modules/";
  languages.java.enable = true;
  languages.java.maven.enable = true;
  languages.java.jdk.package = pkgs.openjdk21;

  # Helpers for migrating old elexis mysql DB and dump
 services.postgres = {
    enable = true;
    package = pkgs.postgresql_17;
    listen_addresses = "0.0.0.0";
    port = 5488;

    initialDatabases = [
      { name = "elexis"; }
    ];

    initdbArgs =
      [
        "--locale=C"
        "--encoding=UTF8"
      ];

    initialScript = ''
      create role elexis superuser login password null;
    '';
  };

  enterShell = ''
    git --version
    java --version
    mvn --version
  '';

}
