{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.gradle;
in
{
  options.features.gradle.enable = lib.mkEnableOption "gradle";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gradle
    ];
  };
}
