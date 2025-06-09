{ lib, pkgs, stdenv, maven }:
with pkgs;
(buildMaven ./project-info.json).build
