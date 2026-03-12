{ config, lib, ... }:

let
  cfg = config.features.zed;
in
{
  options.features.zed.enable = lib.mkEnableOption "zed";
  config = lib.mkIf cfg.enable {
    xdg.configFile = config.lib.dotfiles.configFiles [
      "zed/settings.json"
    ];
  };
}
