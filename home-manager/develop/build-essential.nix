{ pkgs, ... }:

{
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
