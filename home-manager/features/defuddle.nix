{ lib, pkgs, ... }:
{
  _description = "Defuddle web content extractor";
  home.packages = lib.optional (pkgs ? defuddle) pkgs.defuddle;
}
