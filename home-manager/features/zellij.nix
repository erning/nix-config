{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.zellij;
in
{
  options.features.zellij.enable = lib.mkEnableOption "zellij";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      zellij
    ];
  };
}
