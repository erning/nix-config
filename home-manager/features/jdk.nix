{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.jdk;
in
{
  options.features.jdk.enable = lib.mkEnableOption "jdk";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      jdk
    ];
  };
}
