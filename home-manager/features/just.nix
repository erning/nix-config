{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.just;
in
{
  options.features.just.enable = lib.mkEnableOption "just";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      just
    ];
  };
}
