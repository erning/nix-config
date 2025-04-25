{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.kotlin;
in
{
  options.features.kotlin.enable = lib.mkEnableOption "kotlin";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kotlin
    ];
  };
}
