{ pkgs, ... }:
{
  _description = "essential build tools (gcc, make, autotools)";
  home.packages = with pkgs; [
    bison
    flex
    fontforge
    makeWrapper
    pkg-config
    gnumake
    gcc
    libiconv
    autoconf
    automake
    libtool
  ];
}
