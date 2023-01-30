{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, devenv, ... } @ inputs:
    let
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = f: builtins.listToAttrs (map (name: { inherit name; value = f name; }) systems);
    in
    {
      packages = forAllSystems
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
            };
            neededPkgs = [
              pkgs.openjdk11
              pkgs.stdenv.cc
            ];
          in
          {
            default = pkgs.callPackage ./elexis-ide {};
            elexis-ide = pkgs.callPackage ./elexis-ide {};
            rcptt = pkgs.callPackage ./rcptt {};
          });
      devShells = forAllSystems
        (system:
          let
            pkgs = import nixpkgs {
              inherit system;
            };
            neededPkgs = [
              pkgs.openjdk17
              pkgs.stdenv.cc
            ];
          in
          {
            default = devenv.lib.mkShell {
              inherit inputs pkgs ;
              modules = [
                {
                  env.NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
                  packages = neededPkgs;
                  env.NIX_LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath neededPkgs}";
                  enterShell = ''
                    echo path to dll "${pkgs.stdenv.cc}/nix-support/dynamic-linker"                    
                    java -version
                  '';
                }
              ];
            };
          });
    };
}
