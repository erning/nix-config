{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.direnv;
in
{
  options.features.direnv.enable = lib.mkEnableOption "direnv";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      direnv
    ];
  };
}
