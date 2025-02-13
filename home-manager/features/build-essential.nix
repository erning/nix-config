{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.build-essential;
in
{
  options.features.build-essential.enable = lib.mkEnableOption "build-essential";

  config = lib.mkIf cfg.enable {
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
  };
}
