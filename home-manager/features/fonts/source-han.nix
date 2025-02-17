{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.fonts.source-han;
in
{
  options.features.fonts.source-han.enable = lib.mkEnableOption "fonts - Source Han";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.unstable; [
      source-han-sans
      source-han-serif
      source-han-mono
    ];
  };
}
