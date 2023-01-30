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
  source = pkgs.fetchgit {
    url = "https://github.com/zdavatz/yus.git";
    sha256 = "sha256-mXpGXIphvZcie6a8ENRs24LEg+wmSIm17soMKKqGZYk="; # pkgs.lib.fakeSha256; #
  };
  homeDir = "/tmp/www_yus";
  pg_version = "14";
in
  # TODO: Missing are the following files:
  # /etc/yus/data/yus.crt
  # /etc/yus/data/yus.key
  # /etc/yus/data/yus.key.enc
  pkgs.writeShellApplication {
    name = "yus";
    runtimeInputs = with pkgs; [
      ruby
      rsync
      git
      shared-mime-info
      gcc
      gnumake
      sudo
    ];
    text = ''
      set -o verbose
      whoami
      mkdir -p ${homeDir}
      rsync -a ${source}/ ${homeDir}/
      chown -R ywesee:users ${homeDir}
      sudo chmod u+rxw ${homeDir}
      cd ${homeDir}
      rm -f Gemfile.*
      ruby -v
      sudo -Hu ywesee bundle exec ruby -v
      sudo -Hu ywesee touch created_by_ywesee
      export FREEDESKTOP_MIME_TYPES_PATH=${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml
      sudo -Hu ywesee bundle config set --local without 'development'
      sudo -Hu ywesee bundle config build.pg --with-pg-config=${pkgs."postgresql_${pg_version}"}/bin/pg_config
      sudo -Hu ywesee FREEDESKTOP_MIME_TYPES_PATH=${pkgs.shared-mime-info}/share/mime/packages/freedesktop.org.xml bundle update
      sudo -Hu ywesee bundle install
      sudo -Hu ywesee bundle exec ruby bin/yusd
    '';
  }
