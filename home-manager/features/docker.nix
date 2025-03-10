{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.docker;
in
{
  options.features.docker.enable = lib.mkEnableOption "docker";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      lazydocker
    ];
  };
}
