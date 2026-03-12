{ config, lib, ... }:

let
  cfg = config.features.ghostty;
in
{
  options.features.ghostty.enable = lib.mkEnableOption "ghostty";
  config = lib.mkIf cfg.enable {
    xdg.configFile = config.lib.dotfiles.configFiles [
      "ghostty/config"
    ];
  };
}
