{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.nodejs;
in
{
  options.features.nodejs.enable = lib.mkEnableOption "nodejs";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs
      bun
    ];
  };
}
